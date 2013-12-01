#!/bin/bash
BACKUP_FOLDER=$1
BUCKET_NAME=$2
FOLDER_TO_SYNC=$(date +%Y/%m/%d -d "yesterday")
DIRECTORY=$BACKUP_FOLDER/$FOLDER_TO_SYNC
if [ -d "$DIRECTORY" ]; then
  aws s3 cp $DIRECTORY s3://$BUCKET_NAME/$FOLDER_TO_SYNC --recursive
else
  echo "$DIRECTORY doesn't exist"
fi
ACCESS_LOGS_FOLDER_TO_SYNC=$BACKUP_FOLDER/access_logs/$FOLDER_TO_SYNC
if [ -d "$ACCESS_LOGS_FOLDER_TO_SYNC" ]; then
  aws s3 cp $ACCESS_LOGS_FOLDER_TO_SYNC s3://$BUCKET_NAME/access_logs/$FOLDER_TO_SYNC --recursive
else
  echo "$ACCESS_LOGS_FOLDER_TO_SYNC doesn't exist"
fi
