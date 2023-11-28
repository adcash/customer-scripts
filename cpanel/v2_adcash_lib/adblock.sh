#!/bin/bash
set -e

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ADCASH_LIB_FILE_NAME="adc-ads-lib"

update () {
   curl --location --request GET "https://youradexchange.com/ad/s2sadblock.php?v=3&format=js" > "$DIR/$ADCASH_LIB_FILE_NAME"
}

COMMAND="bash $DIR/$0 get"
if [ "$1" = "add" ]; then
	(crontab -l ; echo "0 * * * * $COMMAND") 2>&1 | grep -v "no crontab" | sort | uniq | crontab -
	update && echo "Installed: Please insert this tag in your website's <head/> tag: <script type=\"text/javascript\" src=\"/$ADCASH_LIB_FILE_NAME\"></script>"
elif [ "$1" = "get" ]; then
	update
elif [ "$1" = "remove" ]; then
	COMMAND="(crontab -l) 2>&1 | grep -v \"no crontab\" | grep -v '$COMMAND' |  sort | uniq | crontab -"
	eval "$COMMAND"

	eval "rm -rf $DIR/$ADCASH_LIB_FILE_NAME"
	echo "Uninstalled: please remove adcash lib tag from your website's <head/> tag"
elif [ "$1" = "removeall" ]; then
	COMMAND="(crontab -l) 2>&1 | grep -v \"no crontab\" | grep -v '$DIR/$0' |  sort | uniq | crontab -"
	eval "$COMMAND"

	eval "rm -rf $DIR/$ADCASH_LIB_FILE_NAME"
	echo "Uninstalled: Please remove adcash lib tag from your website's <head/> tag"
elif [ "$1" = "uninstall" ]; then
	eval "bash $DIR/$0 removeall"
	eval "rm $DIR/$0"
	echo "Adcash Adblock Is Completely Removed"
else
	echo "Usage: bash $0 add|get|remove|removeall"
	exit 1
fi

exit 0
