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
