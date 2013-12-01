#!/bin/bash
BACKUP_FOLDER=$1
RDB_FILEPATH=$2
NGINX_LOGS_DIR=$3
TIMESTAMP=$(redis-cli lastsave)

copyLogsFile()
{
  for file in $NGINX_LOGS_DIR/access.log*gz
  do
    FILENAME=$(basename $file)
    FILENAME="${FILENAME%.*}"
    REGEX='[0-9]{10}'
    if [[ $FILENAME =~ $REGEX ]]
    then
      #DAY_FOLDER=$(date --date @${BASH_REMATCH[0]} +%Y/%m/%d)
      DAY_FOLDER="2013/11/28"
      DEST_FOLDER=$BACKUP_FOLDER//access_logs/$DAY_FOLDER
      mkdir -p $DEST_FOLDER
      #ext=$(date --date @${BASH_REMATCH[0]} +%H-%M-%S)
      ext="12-30-14"
      cp -n $file $DEST_FOLDER/$FILENAME-$ext.gz
    fi
  done
}

copyRDBFile()
{
  TIMESTAMP=$(redis-cli lastsave)
  #DAY_FOLDER=$(date --date @$TIMESTAMP +%Y/%m/%d)
  DAY_FOLDER="2013/11/28"
  mkdir -p $BACKUP_FOLDER/$DAY_FOLDER
  #FILE_NAME=$(date --date @$TIMESTAMP +%H-%M-%S)
  FILE_NAME="21-23-23"
  DEST_RDB_FILE_PATH=$BACKUP_FOLDER/$DAY_FOLDER/$FILE_NAME.rdb
  cp $RDB_FILEPATH $DEST_RDB_FILE_PATH
  gzip $DEST_RDB_FILE_PATH
}

monthlyBackup()
{
  #MONTH=$(date +%Y/%m)
  MONTH="2013/12"
  MONTH_FOLDER=$BACKUP_FOLDER/$MONTH/monthly_backup
  mkdir -p $MONTH_FOLDER
  rm -rfv $MONTH_FOLDER/*
  cp $DEST_RDB_FILE_PATH.gz $MONTH_FOLDER/$(basename $DEST_RDB_FILE_PATH).gz
}

weeklyBackup()
{
  #MONTH=$(date +%Y/%m)
  MONTH="2013/12"
  WEEK_BACKUPS_FOLDER=$BACKUP_FOLDER/$MONTH/weekly_backup
  mkdir -p $WEEK_BACKUPS_FOLDER
  CURRENT_WEEK_BACKUPS_FOLDER=$WEEK_BACKUPS_FOLDER/$(date +%d)
  mkdir -p $CURRENT_WEEK_BACKUPS_FOLDER
  rm -rfv $CURRENT_WEEK_BACKUPS_FOLDER/*
  cp $DEST_RDB_FILE_PATH.gz $CURRENT_WEEK_BACKUPS_FOLDER/$(basename $DEST_RDB_FILE_PATH).gz
}

copyLogsFile
copyRDBFile
if [ $(date +%d) == "01" ]
then
  monthlyBackup
fi

if [ $(date +%u) == "7" ]
then
  weeklyBackup
fi
