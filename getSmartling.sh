#!/bin/bash

#
# NAME
#       getSmartling.sh - a bash script to download translated i18n files from Smartling
#
# SYNOPSIS
#       getSmartling.sh [LOCALE] [FILE NAME]
#
# EXAMPLE
#				To output to stdout:
#       	getSmartling.sh fr-FR 
#
#				To output to a file:
#       	getSmartling.sh fr-FR fr-FR.xml
#

LOCALE="$1"
FILENAME="$2"

# enter your Smartling API info
SMARTLING_API_KEY="YOUR_SMARTLING_API_KEY"
SMARTLING_PROJECT_ID="YOUR_SMARTLINK_PROJECT_KEY"
SMARTLING_FILE_URI="YOUR_SMARTLINK_FILE_URI"

# you shouldn't need to modify anything below
SMARTLING_API_PROJECT_ID="apiKey=$SMARTLING_API_KEY&projectId=$SMARTLING_PROJECT_ID"
SMARTLING_GET_API_URL="https://api.smartling.com/v1/file/get"
CURL_POST_DATA="$SMARTLING_API_PROJECT_ID&fileUri=$SMARTLING_FILE_URI&locale=$LOCALE"

if test $# -eq 0
then
	echo "Usage: getSmartling [locale] [filename]\neg. getSmartling fr-FR\neg. getSmartling fr-FR fr-FR.xml" 
	echo "======================================================================="
	echo "Available locale codes (pulled in realtime from Smartling...may take a sec):"
	curl -s -k -d $SMARTLING_API_PROJECT_ID "https://api.smartling.com/v1/project/locale/list" | sed -e 's/[{}]/''/g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | grep '"locale":' | sed 's/:/ /1' | awk -F" " '{ print $2 }'
else
	echo "======================================================================="
	echo "Downloading locale from Smartling: [$LOCALE]"
	echo "======================================================================="
	
	if test $# -eq 2
	then
		# output to file
		curl -k -d $CURL_POST_DATA $SMARTLING_GET_API_URL -o $FILENAME
	else
		# output to stdout
		curl -k -d $CURL_POST_DATA $SMARTLING_GET_API_URL
	fi
fi
