#!/bin/bash
BUCKET_NAME=$1
FOLDER_TO_CHECK=$(date +%Y/%m/%d -d "yesterday")
RESPONSE=$(aws s3 ls s3://$BUCKET_NAME/$FOLDER_TO_CHECK)

if echo "$RESPONSE" | grep ".gz"; then
  echo "matched"
else
  echo "No S3 backups for $FOLDER_TO_CHECK." | mail -s "Action Counter Monitor" ron@ftbpro.com, dor@ftbpro.com, shai@ftbpro.com
fi
