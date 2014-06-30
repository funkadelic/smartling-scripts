#!/bin/sh

#
# svn post-commit hook to upload your localization file to 
# Smartling and get email notification
#
# == INSTALLATION ==
#
# Copy this file into your svn hooks directory for the repo that you want to use
# this post-commit script in (eg. /path/to/svn/somerepo/hooks/) and add a line to 
# post-commit and call it with the following:
#
#    /path/to/svn/repo/hooks/post-commit.smartling.sh "$REPOS" "$REV"
#
# (you should have $REPOS and $REV defined already in the post-commit script)
#

SMARTLING_API_KEY="YOUR_SMARTLING_API_KEY"
SMARTLING_PROJECT_ID="YOUR_SMARTLINK_PROJECT_KEY"
SMARTLING_FILE_URI="YOUR_SMARTLINK_FILE_URI"
# email recipients comma-separated
EMAIL_RECIPIENTS="bob@example.com,bill@example.com"
# path to your language file
SOURCE_FILE_PATH="file:///svn/repos/somerepo/trunk/i18n/en_US.xml"
# file path to match the file we are looking for. A match means we will 
# upload $SOURCE_FILE_PATH to Smartling. Note that is path is reported by
# svn and will be different than what is set in $SOURCE_FILE_PATH. Simply
# matching the file name will work if you have no other similarly named
# files in your repo, but it would be more foolproof if you specify something 
# more unique like a specific directory path
CHANGED_FILE_MATCH_PATH="trunk/somerepo/i18n/en_US.xml"

REPOS="$1"
REV="$2"
TIMESTAMP=`/bin/date +%Y%m%d-%H%M`
EXPORT_FILE="en_US-$TIMESTAMP.xml"
EXPORT_FILE_PATH="/tmp/$EXPORT_FILE"
SMARTLING_UPLOAD_PATH="file=@$EXPORT_FILE_PATH;type=text/plain"

CHANGED_FILES=`/usr/bin/svnlook changed -r "$REV" "$REPOS"`

#get the log message
COMMIT_MESSAGE=`/usr/bin/svnlook log -r "$REV" "$REPOS"`

#get the author
COMMIT_AUTHOR=`/usr/bin/svnlook author -r "$REV" "$REPOS"`

# uncomment for testing on the command line
#echo ""
#echo "###"
#echo "Time: $TIMESTAMP"
#echo "Changed files for $REV:"
#echo $CHANGED_FILES
#echo "---"
#echo "author: $COMMIT_AUTHOR"
#echo "---"
#echo "message: $COMMIT_MESSAGE"
#echo "---"
#echo "export path: $EXPORT_FILE_PATH"
#echo "SMARTLING_UPLOAD_PATH: $SMARTLING_UPLOAD_PATH"
#echo "###"

if [[ "$CHANGED_FILES" =~ $CHANGED_FILE_MATCH_PATH ]]
then

    /usr/bin/svn export -q --non-interactive --trust-server-cert $SOURCE_FILE_PATH $EXPORT_FILE_PATH

    API_RESPONSE=$(/usr/bin/curl -ksS\
    -F "file=@$EXPORT_FILE_PATH;type=text/plain"\
    -F "apiKey=$SMARTLING_API_KEY"\
    -F "projectId=$SMARTLING_PROJECT_ID"\
    -F "fileType=xliff"\
    -F "fileUri=$SMARTLING_FILE_URI"\
    "https://api.smartling.com/v1/file/upload")

    #echo "APL_RESPONSE: $API_RESPONSE"

    # notify via email
    BODY="\n\n[SVN REVISION]\n$REV\n\n\
[AUTHOR]\n$COMMIT_AUTHOR\n\n\
[COMMIT MESSAGE]\n$COMMIT_MESSAGE\n\n\
[Smartling API RESPONSE]\n$API_RESPONSE"

    echo -e $BODY | /bin/mail -s "[svn post-commit] upload to Smartling" $EMAIL_RECIPIENTS

fi
