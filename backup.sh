#!/bin/bash
# RUN THIS SCRIPT DIRECTLY FROM THE HOST MACHINE, NOT FROM WITHIN THE DOCKER CONTAINER!
BACKUP_DIR="`dirname $0`/backups"
WD=`pwd`
cd $BACKUP_DIR/..

echo '---'
echo 'Shutting down SVN Server...'

# Temporarily shut down the SVN Server until the backup procedure has finished.
sudo docker-compose down

echo "Backing up the entire SVN Server instance into $BACKUP_DIR/"
echo 'This might take a while, perhaps go grab a coffee...'

# Ensure that the backup output directory exists.
sudo mkdir -p $BACKUP_DIR

# Make sure that this is the full, 
# absolute path to the directory where
# the SVN Server container volume is mounted to.
VOL_DIR=/mnt/dev/svn/

# Get the current time for the output file name.
TIMESTAMP=`date +"%Y-%m-%d-%H-%M-%S"`

# Construct the output file path using the timestamp.
OUTPUT_FILE_PATH=$BACKUP_DIR/$TIMESTAMP-svn-server-backup.tar.gz

# Compress the entire SVN Server instance into a tar.gz archive.
sudo tar -zcvf $OUTPUT_FILE_PATH $VOL_DIR

echo '---'
echo "SVN Server backup was exported into $OUTPUT_FILE_PATH"
echo 'Maybe consider encrypting the archive using a strong password + 7z (choose ENCRYPT FILE NAMES TOO  when asked).'
echo '---'
echo 'Restarting SVN Server after backup...'

sudo docker-compose up -d
cd $WD
