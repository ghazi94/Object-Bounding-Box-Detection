#!/bin/bash

cd /tmp/MATRUN/
PROCESSED_FILE=$1
FILE_MEDIUM_SIZED=$2
ORIGINAL_FILE=$3
MESSAGE_RECEIPT_HANDLE=$4

# The bucket to upload to
S3_BUCKET="your-s3-bucket"
# The folder path to the processed file - same as the key to store in S3
S3_KEY="$PROCESSED_FILE"
# Delete the message from the SQS first
aws sqs delete-message --queue-url https://your-queue-aws-url --receipt-handle "$MESSAGE_RECEIPT_HANDLE"
# Copy the processed file to S3
aws s3 cp "$S3_KEY" "s3://$S3_BUCKET/Ver_3.0_$S3_KEY" | grep '$$##$$'
# Remove all the files now
rm "$PROCESSED_FILE"
rm "$FILE_MEDIUM_SIZED"
rm "$ORIGINAL_FILE"
