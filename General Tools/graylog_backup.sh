#/bin/bash
BACKUP_LOG="/backup/backup.log"
BACKUP_DIR="/media/backup"
echo `date` >> $BACKUP_LOG
APP_NAME="vslogs"
TIMESTAMP=`date +%F-%H%M`
BACKUP_NAME="$BACKUP_DIR/$APP_NAME-$TIMESTAMP"
mkdir -p $BACKUP_NAME
echo "Deleting following backup files older than 30 days:" >> $BACKUP_LOG
find $BACKUP_DIR -type d -name "$APP_NAME-*" -mtime +30 >> $BACKUP_LOG
find $BACKUP_DIR -type d -name "$APP_NAME-*" -mtime +30 -exec rm -rf {}
echo "Starting daily backup of $APP_NAME ...." >> $BACKUP_LOG
/usr/bin/mongodump --archive="$BACKUP_NAME/$APP_NAME.gz" --gzip
cp /etc/graylog/server/server.conf $BACKUP_NAME
echo "End of backup run" >> $BACKUP_LOG
echo "----------------------------------" >> $BACKUP_LOG
