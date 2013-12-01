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
      DAY_FOLDER=$(date --date @${BASH_REMATCH[0]} +%Y/%m/%d)
      DEST_FOLDER=$BACKUP_FOLDER//access_logs/$DAY_FOLDER
      mkdir -p $DEST_FOLDER
      EXT=$(date --date @${BASH_REMATCH[0]} +%H-%M-%S)
      cp -n $file $DEST_FOLDER/$FILENAME-$EXT.gz
    fi
  done
}

copyRDBFile()
{
  TIMESTAMP=$(redis-cli lastsave)
  DAY_FOLDER=$(date --date @$TIMESTAMP +%Y/%m/%d)
  mkdir -p $BACKUP_FOLDER/$DAY_FOLDER
  FILE_NAME=$(date --date @$TIMESTAMP +%H-%M-%S)
  DEST_RDB_FILE_PATH=$BACKUP_FOLDER/$DAY_FOLDER/$FILE_NAME.rdb
  cp $RDB_FILEPATH $DEST_RDB_FILE_PATH
  gzip $DEST_RDB_FILE_PATH
}

monthlyBackup()
{
  MONTH=$(date +%Y/%m)
  MONTH_FOLDER=$BACKUP_FOLDER/$MONTH/monthly_backup
  mkdir -p $MONTH_FOLDER
  rm -rfv $MONTH_FOLDER/*
  cp $DEST_RDB_FILE_PATH.gz $MONTH_FOLDER/$(basename $DEST_RDB_FILE_PATH).gz
}

weeklyBackup()
{
  MONTH=$(date +%Y/%m)
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

#Sunday's
if [ $(date +%u) == "7" ]
then
  weeklyBackup
fi
