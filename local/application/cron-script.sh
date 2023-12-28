#!/bin/bash

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
rm $DESTINATION_FOLDER* 

mv $UPLOAD_FOLDER* $DESTINATION_FOLDER
rm $UPLOAD_FOLDER* 

# Classify daily pictures (for logs):
/usr/local/bin/python3 /app/classify_daily.py

# Archive logs and daily results (locally)
cp $LOG_FILE $ARCHIVE_FOLDER
cp $DAILY_RES $ARCHIVE_FOLDER

echo "Update complete at $(date)"
