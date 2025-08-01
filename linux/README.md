# Anti-Adblock Integration Guide for Linux

This guide will help you set up an integration that allows ads to appear on your website, even when visitors are using an ad blocker.

## Prerequisites

Before you begin, ensure the following:

1. You have administrator access to your website’s server (via hosting account or SSH).
2. The server has both [curl](https://linuxize.com/post/curl-command-examples/) and [crontab](https://linuxize.com/post/scheduling-cron-jobs-with-crontab/) installed

_(If you’re unsure, your hosting provider or developer can confirm this.)_

## Steps

1. **Download the Installer Script**

   The installer helps set up and manage the Anti-Adblock Library.

   1. Log in to your server or hosting environment (typically via SSH or a terminal).
   2. Navigate to a non-public directory (not accessible from the web).
   3. Run the following command to download the script:

   ```bash
   curl -o anti-adblock.sh https://raw.githubusercontent.com/adcash/customer-scripts/master/linux/anti-adblock.sh
   ```

2. **Make the Script Executable**

   Give the script permission to run by running:

   ```bash
   chmod +x anti-adblock.sh
   ```

3. **(Optional) View the Script Help Menu**

   To view all available options:

   ```bash
   ./anti-adblock.sh --help
   ```

4. **Install the Anti-Adblock Library**

   This step downloads the Anti-Adblock Library (a JavaScript file) and sets it up to automatically update at regular intervals, ensuring it stays effective against evolving ad blockers.

   You’ll need to specify:

   - The **location** where the file should be saved _(This must be a public directory that your website can access – for example, where your other JavaScript files are served from)_
   - A **random filename** for the file to help avoid detection by ad blockers
   - The **update frequency**, in minutes _(Recommended: every 5 minutes)_

   Command format:

   ```bash
   ./anti-adblock.sh --install <path_to_public_directory/randomname.js> <update_frequency_in_minutes>
   ```

   `<path_to_public_directory/randomname.js>` – Full path to your public website directory, followed by a randomly chosen filename.

   `<update_frequency_in_minutes>` – How often the script should automatically update. Recommended: 5

    <br>

   **Example:**
   If you’re using an Nginx server on Ubuntu, the default public directory is `/var/www/html/`. To install the script there (with a filename `lib.js`) and update it every 5 minutes:

   ```bash
   ./anti-adblock.sh --install /var/www/html/lib.js 5
   ```

   Expected output if successful:

   ```bash
    File downloaded to /var/www/html/lib.js
    Setting up a new cron job for lib.js.
    Cron job set to download lib.js to /var/www/html/lib.js every 5 minute(s).
    Install completed.
   ```

   You can also validate the installation by running:

   ```bash
   ./anti-adblock.sh --list
   ```

5. **Include the Anti-Adblock Library Script in Your Website:**

   Add the following snippet to your webpage HTML.

   **Best practice:** Place it as high as possible within the `<head>` section for proper loading.

   ```html
   <script type="text/javascript" src="lib.js"></script>
   ```

   ⚠️ **Important:**

   - _Replace `lib.js` with the correct file path and name you used during the installation._
   - _Include only one instance of this script per page._

6. **Initialize Ads**

   Add this snippet 🚨 **after** the library script tag, such as in the body or footer:

   ```html
   <script>
     aclib.runDESIRED_FORMAT_HERE({ zoneId: '<ZONE_ID_HERE>' });
   </script>
   ```

   ⚠️ **Replace:**

   - `DESIRED_FORMAT_HERE` with the right ad format (e.g., `Pop`, `InPagePush`, `Banner`, `Interstitial`, `AutoTag`, `VideoSlider`)
   - `<ZONE_ID_HERE>` with the actual zone ID

7. **Done!**

   Ads should now appear on your site even with Adblock enabled.

   To confirm the script is working:

   1. Open your website in a browser with Adblock turned on.
   2. Press **F12** to open Developer Tools.
   3. Go to the **Network** tab.
   4. Refresh the page and confirm that `lib.js` loads successfully without errors.

## Best Practices & Tips

- If the library script file becomes blocked by ad blockers, uninstall it using the `--uninstall` option, then reinstall it using a new random filename to bypass detection
- Use obscure, non-obvious filenames for the anti-adblock library js file (e.g. t48s7z.js).
- Rotate the filename periodically to avoid long-term detection.
- Don't hard-code the filename in multiple places – use a config or variable if possible.
- Monitor Anti-Adblock effectiveness using A/B testing or custom events in analytics.
