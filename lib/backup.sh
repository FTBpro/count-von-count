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
    regex='[0-9]{10}'
    if [[ $FILENAME =~ $regex ]]
    then
      FOLDER=$(date --date @${BASH_REMATCH[0]} +%Y/%m/%d)
      ext=$(date --date @${BASH_REMATCH[0]} +%H-%M-%S)
      $(mkdir -p $BACKUP_FOLDER/$FOLDER)
      $(cp -n $file $BACKUP_FOLDER/$FOLDER/$FILENAME-$ext.gz)
    fi
  done
}

copyRDBFile()
{
  TIMESTAMP=$(redis-cli lastsave)
  FOLDER=$(date --date @$TIMESTAMP +%Y/%m/%d)
  FILE_NAME=$(date --date @$TIMESTAMP +%H-%M-%S)
  $(mkdir -p $BACKUP_FOLDER/$FOLDER)
  $(cp $RDB_FILEPATH $BACKUP_FOLDER/$FOLDER/$FILE_NAME.rdb)
}

copyLogsFile
copyRDBFile
