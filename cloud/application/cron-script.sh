#!/bin/bash

export AWS_ACCESS_KEY_ID="insertyourawsaccesskeyhere"
export AWS_SECRET_ACCESS_KEY="insertyourawssecretkeyhere"
export AWS_DEFAULT_REGION=eu-west-1

S3_BUCKET="bucketfm2p"
S3_BUCKET2="bucketlogsfm2p"

DESTINATION_FOLDER="/app/downloads/"
UPLOAD_FOLDER="/app/uploads/"
LOG_FILE="/app/logs/$(date '+%Y-%m-%d').log"            # application log (general)
DAILY_RES="/app/logs/results-$(date '+%Y-%m-%d').log"   # classified results log

# Delete images at 00:00 (locally)
rm $DESTINATION_FOLDER*
rm $UPLOAD_FOLDER*

# Download files from S3 to local:
aws s3 sync s3://$S3_BUCKET $DESTINATION_FOLDER

# Classify pictures and log the results:
/usr/local/bin/python3 /app/classify_daily.py
aws s3 cp $DAILY_RES s3://$S3_BUCKET2/$(date '+%Y-%m-%d')/

# Archive and Log (cloud):
aws s3 cp $DESTINATION_FOLDER s3://$S3_BUCKET2/$(date '+%Y-%m-%d')/ --recursive

aws s3 cp $LOG_FILE s3://$S3_BUCKET2/$(date '+%Y-%m-%d')/

# Empty bucket (cloud)
aws s3 rm s3://$S3_BUCKET --recursive

echo "Images synced from S3 bucket $S3_BUCKET to S3 bucket $S3_BUCKET2 at $(date)"

