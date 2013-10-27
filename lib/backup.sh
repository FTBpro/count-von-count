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
      FOLDER=$(date -r ${BASH_REMATCH[0]} +%Y/%m/%d)
      ext=$(date -r ${BASH_REMATCH[0]} +%H-%M-%S)
      $(mkdir -p $BACKUP_FOLDER/$FOLDER)
      $(cp -n $file $BACKUP_FOLDER/$FOLDER/$FILENAME-$ext.gz)
    fi
  done
}

copyRDBFile()
{
  TIMESTAMP=$(redis-cli lastsave)
  FOLDER=$(date -r $TIMESTAMP +%Y/%m/%d)
  file_name=$(date -r $TIMESTAMP +%H-%M-%S)
  $(mkdir -p $BACKUP_FOLDER/$FOLDER)
  $(cp $RDB_FILEPATH $BACKUP_FOLDER/$FOLDER/$file_name.rdb)
}

copyLogsFile
copyRDBFile
