#!/bin/bash
set -e

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

update () {
   curl --location --request GET "https://adbpage.com/adblock?zone_id=$2&zone_type=$1&v=2" > "$DIR/z-$2"
}

if [ "$1" != "removeall" ] && [ "$1" != "uninstall" ]; then
	if [ "$2" != "suv4" ] && [ "$2" != "atag" ]; then
		echo "Usage: bash $0 add|get|remove|removeall|uninstall suv4|atag [ZONE_ID]"
		exit 1
	fi
fi

COMMAND="bash $DIR/$0 get $2 $3"
if [ "$1" = "add" ]; then
	(crontab -l ; echo "0 * * * * $COMMAND") 2>&1 | grep -v "no crontab" | sort | uniq | crontab -
	update $2 $3 && echo "Installed: Please insert this tag on your pages: <script type=\"text/javascript\" src=\"/z-$3\"></script>"
elif [ "$1" = "get" ]; then
	update $2 $3
elif [ "$1" = "remove" ]; then
	COMMAND="(crontab -l) 2>&1 | grep -v \"no crontab\" | grep -v '$COMMAND' |  sort | uniq | crontab -"
	eval "$COMMAND"

	eval "rm -rf $DIR/z-$3"
	echo "Uninstalled: please remove the following tag from your pages - <script type=\"text/javascript\" src=\"/z-$3\"></script>"
elif [ "$1" = "removeall" ]; then
	COMMAND="(crontab -l) 2>&1 | grep -v \"no crontab\" | grep -v '$DIR/$0' |  sort | uniq | crontab -"
	eval "$COMMAND"

	eval "rm -rf $DIR/z-*"
	echo "Uninstalled all: please remove all tag from your pages that look like - <script type=\"text/javascript\" src=\"/z-*\"></script>"
elif [ "$1" = "uninstall" ]; then
	eval "bash $DIR/$0 removeall"
	eval "rm $DIR/$0"
	echo "Adcash Adblock Is Completely Removed"
else
	echo "Usage: bash $0 add|get|remove|removeall suv4|atag [ZONE_ID]"
	exit 1
fi

exit 0
