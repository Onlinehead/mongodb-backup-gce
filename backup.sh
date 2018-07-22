#!/bin/bash
set -o pipefail
set -o errexit
set -o errtrace
set -o nounset

# Settings
DB_HOST="$DB_HOST"
DB_NAME="$DB_NAME"
DB_USER="$DB_USER"
DB_PASS="$DB_PASS"
BUCKET_NAME="$BUCKET_NAME"
PROJECT_ID="$PROJECT_ID"
SERVICE_ACCOUNT="$SERVICE_ACCOUNT"

# Path in which to create the backup (will get cleaned later)
BACKUP_PATH="/dump/"
G_KEY_PATH="/var/secrets/google/key.json"

CURRENT_DATE=$(date +"%Y%m%d-%H%M")

# Backup filename
BACKUP_FILENAME="$DB_NAME-$CURRENT_DATE.tar.gz"

# Authorize in Google Cloud
gcloud auth activate-service-account $SERVICE_ACCOUNT --key-file=$G_KEY_PATH
gcloud config set project $PROJECT_ID

# Create backup dir
mkdir -p $BACKUP_PATH

# Create the backup
mongodump -h "$DB_HOST" -d "$DB_NAME" -u "$DB_USER" -p "$DB_PASS" -o "$BACKUP_PATH"
cd $BACKUP_PATH || exit 1

# Archive and compress
tar -cvzf "$BACKUP_PATH""$BACKUP_FILENAME" ./*

# Copy to Google Cloud Storage
echo "Copying $BACKUP_PATH$BACKUP_FILENAME to gs://$BUCKET_NAME/$DB_NAME/"
gsutil cp "$BACKUP_PATH""$BACKUP_FILENAME" gs://"$BUCKET_NAME"/"$DB_NAME"/ 2>&1
echo "Copying finished"
echo "Removing backup data"
rm -rf $BACKUP_PATH*
