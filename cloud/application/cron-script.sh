#!/bin/bash

# export AWS_ACCESS_KEY_ID=$(awk -F= '/^AWS_ACCESS_KEY=/{gsub(/[ \t]+$/, "", $2); print $2}' /app/.env)
# export AWS_SECRET_ACCESS_KEY=$(awk -F= '/^AWS_SECRET_KEY=/{gsub(/[ \t]+$/, "", $2); print $2}' /app/.env)

export AWS_ACCESS_KEY_ID=insertyourawsaccesskeyhere
export AWS_SECRET_ACCESS_KEY=insertyourawssecretkeyhere

export AWS_DEFAULT_REGION=eu-west-1
S3_BUCKET="bucketfm2p"
S3_BUCKET2="bucketlogsfm2p"

DESTINATION_FOLDER="/app/downloads/"
ARCHIVE_FOLDER="/app/archive/$(date '+%Y-%m-%d'-%h)/"
UPLOAD_FOLDER="/app/uploads/"
LOG_FILE="/app/logs/$(date '+%Y-%m-%d').log"
DAILY_RES="/app/logs/results-$(date '+%Y-%m-%d').log"

# Create the destination folder if it doesn't exist
mkdir -p $DESTINATION_FOLDER
mkdir -p $ARCHIVE_FOLDER

# Archive todays images (locally)
mv $DESTINATION_FOLDER* $ARCHIVE_FOLDER

# Archive and Log (cloud):
aws s3 cp "${ARCHIVE_FOLDER}/" "s3://${S3_BUCKET2}/$(date '+%Y-%m-%d'-%h)/" --recursive
aws s3 cp $LOG_FILE s3://$S3_BUCKET2/$(date '+%Y-%m-%d'-%h)/
echo "Daily archive successful."

# Delete todays images (locally)
rm $DESTINATION_FOLDER* 
rm $UPLOAD_FOLDER*        

# Download files from S3 to local:
aws s3 sync s3://$S3_BUCKET $DESTINATION_FOLDER

# Classify daily pictures (for logs):
/usr/local/bin/python3 /app/classify_daily.py
aws s3 cp $DAILY_RES s3://$S3_BUCKET2/$(date '+%Y-%m-%d'-%h)/

# Delete images (cloud)
aws s3 rm s3://$S3_BUCKET --recursive

echo "Images synced from S3 bucket $S3_BUCKET to $DESTINATION_FOLDER at $(date)"
