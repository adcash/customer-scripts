#!/bin/bash

if ! command -v curl &> /dev/null; then
    echo "Error: 'curl' is not installed or not in PATH."
    exit 1
fi

if ! command -v crontab &> /dev/null; then
    echo "Error: 'crontab' command not found. Is cron installed?"
    exit 1
fi

# === CONFIGURATION ===
FILE_URL="https://adbpage.com/adblock?v=3&format=js&lnxv=2"
SCRIPT_NAME="$(basename "$0")"
CRON_MARKER="# added-by-adblock"

show_help() {
    echo "Usage: ${SCRIPT_NAME} [option] <target_file_path> <frequency_in_minutes>"
    echo ""
    echo "Options:"
    echo "  --install         Download the library file and set up a cron job."
    echo "  --uninstall       Remove the file and its associated cron job."
    echo "  --list            Show all cron jobs managed by this script."
    echo "  --help            Display this help message."
    echo ""
    echo "Arguments:"
    echo "  target_file_path       Path to where the file will be saved."
    echo "  frequency_in_minutes   How often (in minutes) the cron job should run."
    echo ""
    echo "Examples:"
    echo ""
    echo "  ${SCRIPT_NAME} --install /var/www/html/lib.js 5"
    echo "      → Downloads the file and sets a cron job to refresh it every 5 minutes."
    echo "        If a job already exists for the file, it will be replaced."
    echo ""
    echo "  ${SCRIPT_NAME} --uninstall /var/www/html/lib.js"
    echo "      → Removes the cron job and deletes the file."
    echo ""
    echo "  ${SCRIPT_NAME} --list"
    echo "      → Shows all cron jobs set up by this script."
    echo ""
    echo "Notes:"
    echo "  • If you provide only a file name (no path), it uses the current directory."
    echo "  • Frequency must be a positive number (in minutes)."
}

build_cron_marker() {
    if [[ -z "$TARGET_FILE_PATH" || -z "$FILE_NAME" ]]; then
        echo "Error: Could not resolve target path." >&2
        exit 1
    fi

    # Current format. The brackets delimit the path so a marker can never be a substring of another.
    CRON_MARKER_NEW="${CRON_MARKER}[${TARGET_FILE_PATH}]"

    # Pre-path-keyed format. File name only, so it does not identify a job on its own.
    CRON_MARKER_LEGACY="${CRON_MARKER} ${FILE_NAME}"

    # Every cron line this script has written redirects into the target with exactly this fragment.
    # The quotes are part of it, so a job for "lib.js" cannot match a line writing "lib.jsx".
    CRON_PATH_ANCHOR="> \"${TARGET_FILE_PATH}\""
}

# True when this crontab line is one of ours for the current target. The current marker is exact on
# its own; the legacy marker also matches other directories, so it counts only with the path anchor.
# Install and uninstall replace the whole crontab, so a loose match deletes someone else's job.
is_cron_line_ours() {
    local line="$1"

    if [[ "$line" == *"$CRON_MARKER_NEW"* ]]; then
        return 0
    fi

    if [[ "$line" != *"$CRON_PATH_ANCHOR"* ]]; then
        return 1
    fi

    [[ "$line" == *"$CRON_MARKER_LEGACY"* ]]
}

# The crontab with our lines for this target taken out — what gets written back. A loop, because
# "marker AND path anchor" is not expressible as a grep -vF chain. `IFS= read -r` plus the `-n`
# continuation keeps every byte, including a final line with no trailing newline.
filtered_crontab() {
    local line

    while IFS= read -r line || [[ -n "$line" ]]; do
        is_cron_line_ours "$line" || printf '%s\n' "$line"
    done < <(crontab -l 2>/dev/null || true)

    return 0
}

# Just our lines for this target, so a message reports the same lines filtered_crontab drops.
matching_cron_lines() {
    local line

    while IFS= read -r line || [[ -n "$line" ]]; do
        if is_cron_line_ours "$line"; then
            printf '%s\n' "$line"
        fi
    done < <(crontab -l 2>/dev/null || true)

    return 0
}

remove_cron_job() {
    build_cron_marker

    local ours
    ours=$(matching_cron_lines)

    if [[ -n "$ours" ]]; then
        # Captured first: the read must finish before crontab - installs over it.
        local updated_cron
        updated_cron=$(filtered_crontab)

        # The guard leaves an emptied crontab empty rather than holding a blank line. The status is
        # checked so a failed write never reports a removal and then deletes the file anyway.
        if ! {
            if [[ -n "$updated_cron" ]]; then
                printf '%s\n' "$updated_cron"
            fi
        } | crontab -; then
            echo "Error: failed to update the crontab. The cron job was not removed." >&2
            return 1
        fi

        echo "Cron job removed for $FILE_NAME."
    else
        echo "No cron job found for $FILE_NAME."
    fi

    if [[ -f "$TARGET_FILE_PATH" ]]; then
        rm -f "$TARGET_FILE_PATH"
        echo "File removed: $TARGET_FILE_PATH"
    else
        echo "No file found at $TARGET_FILE_PATH."
    fi
}

download_lib() {
    if [[ -e "$TARGET_FILE_PATH" && ! -w "$TARGET_FILE_PATH" ]]; then
        echo "Error: File exists but is not writable: $TARGET_FILE_PATH"
        return 1
    elif [[ ! -e "$TARGET_FILE_PATH" && ! -w "$(dirname "$TARGET_FILE_PATH")" ]]; then
        echo "Error: Cannot write to directory: $(dirname "$TARGET_FILE_PATH")"
        return 1
    fi

    if curl -s --fail --location --output "$TARGET_FILE_PATH" "$FILE_URL"; then
        return 0
    else
        echo "Error: Failed to download from $FILE_URL"
        return 1
    fi
}

write_cron_job() {
    build_cron_marker

    # Same predicate as the removal, so the message describes the lines the write drops.
    local ours
    ours=$(matching_cron_lines)

    if [[ -z "$ours" ]]; then
        echo "Setting up a new cron job for $FILE_NAME."
    elif [[ "$ours" == *"$CRON_MARKER_NEW"* ]]; then
        echo "An existing cron job for $FILE_NAME was found. It will be overwritten."
    else
        echo "An existing cron job for $FILE_NAME was found in the old format. It will be replaced."
    fi

    local existing_cron
    existing_cron=$(filtered_crontab)

    local curl_bin
    curl_bin=$(command -v curl)

    local cron_command
    cron_command="lib_content=\$($curl_bin -s --fail --location \"$FILE_URL\"); if [[ \$? -eq 0 ]]; then echo \"\$lib_content\" > \"$TARGET_FILE_PATH\"; fi"

    # The `> "$TARGET_FILE_PATH"` in cron_command is the path anchor. Changing that redirect or its
    # quoting breaks uninstall for every pre-path-keyed install in the field.
    local cron_job="*/$FREQUENCY_MINUTES * * * * bash -c '$cron_command' > /dev/null 2>&1 $CRON_MARKER_NEW"

    if ! {
        if [[ -n "$existing_cron" ]]; then
            printf '%s\n' "$existing_cron"
        fi
        printf '%s\n' "$cron_job"
    } | crontab -; then
        echo "Error: failed to update the crontab. The file will not refresh automatically." >&2
        return 1
    fi

    echo "Cron job set to download $FILE_NAME to $TARGET_FILE_PATH every $FREQUENCY_MINUTES minute(s)."
}

list_cron_jobs() {
    local count=1

    while IFS= read -r cron_line || [[ -n "$cron_line" ]]; do
        local frequency file_path file_name

        # Leading whitespace is legal on a cron line, and `IFS= read` keeps it.
        if [[ "$cron_line" =~ ^[[:space:]]*\*/([0-9]+) ]]; then
            frequency="${BASH_REMATCH[1]}"
        else
            frequency="?"
        fi

        file_path=$(echo "$cron_line" | grep -oE '> "[^"]+"' | cut -d'"' -f2)
        file_name=$(basename "$file_path" 2>/dev/null || echo "?")

        echo "($count) File: $file_name | Path: $file_path | Frequency: Every $frequency minute(s)"
        ((count++))
    # One pattern covers both formats: the path-keyed marker starts with the same base string.
    done < <(crontab -l 2>/dev/null | grep -F "$CRON_MARKER")

    if [[ $count -eq 1 ]]; then
        echo "No active cron jobs found for this script."
    fi
}

# === Argument Parsing ===
if [[ $# -eq 0 ]]; then
    echo "No arguments provided."
    show_help
    exit 1
fi

case "$1" in
    --help)
        show_help
        exit 0
        ;;
    --list)
        shift
        list_cron_jobs
        exit 0
        ;;
    --uninstall)
        if [[ $# -ne 2 ]]; then
            echo "Error: The uninstall option requires one argument."
            show_help
            exit 1
        fi
        TARGET_FILE_PATH=$(realpath "$2")
        FILE_NAME="$(basename "$TARGET_FILE_PATH")"
        if ! remove_cron_job; then
            exit 1
        fi
        echo "Uninstall completed."
        exit 0
        ;;
    --install)
        if [[ $# -ne 3 ]]; then
            echo "Error: The install option requires a file path and frequency."
            show_help
            exit 1
        fi

        TARGET_FILE_PATH=$(realpath "$2")
        FILE_NAME="$(basename "$TARGET_FILE_PATH")"
        FREQUENCY_MINUTES="$3"

        if ! [[ "$FREQUENCY_MINUTES" =~ ^[0-9]+$ ]]; then
            echo "Error: Frequency must be a number."
            exit 1
        fi

        download_lib
        DOWNLOAD_STATUS=$?
        if [ $DOWNLOAD_STATUS -ne 0 ]; then
            echo "Download failed during installation. Exiting."
            exit 1
        fi

        echo "File downloaded to $TARGET_FILE_PATH"
        if ! write_cron_job; then
            exit 1
        fi
        echo "Install completed."
        exit 0
        ;;
    *)
        echo "Error: Invalid option."
        show_help
        exit 1
        ;;
esac

echo "No action was taken. Use --help for usage information."
exit 1
