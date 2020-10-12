#!/bin/bash

cd /tmp/MATRUN/
# Due to visbility timout settings, an inflight message won't be viisible to other
# consumers for 10 minutes. This is MORE THAN sufficient for MATLAB to process 
# and delete the message
SQS_MESSAGE=$(aws sqs receive-message --queue-url https://your-queue-aws-url.com --attribute-names All --message-attribute-names All --max-number-of-messages 1)
S3_BUCKET=$(echo "$SQS_MESSAGE" | jsawk 'return this.Messages[0].Body' | jsawk 'return this.Message' | jsawk 'return this.Records[0].s3.bucket.name')
S3_KEY=$(echo "$SQS_MESSAGE" | jsawk 'return this.Messages[0].Body' | jsawk 'return this.Message' | jsawk 'return this.Records[0].s3.object.key')
# Receipt Handle is used to delete the message
MESSAGE_RECEIPT_HANDLE=$(echo "$SQS_MESSAGE" | jsawk 'return this.Messages[0].ReceiptHandle')
RAW_CHECK=$(echo "$S3_KEY" | grep "RAW")
# Deduce the directory structure
SAVE_DESTINATION=$(echo "$S3_KEY" | sed "s/RAW/EDITED/g" | sed "s/EDITED\/.*JPG//g" | sed "s/EDITED\/.*jpg//g")
EDITED_STRING="EDITED/"
FINAL_SAVE_DIR="$SAVE_DESTINATION$EDITED_STRING"
# Make the directory
mkdir -p "$FINAL_SAVE_DIR"
# Extract the file key as an edited file
FINAL_FILE_NAME=$(echo "$S3_KEY" | sed "s/RAW/EDITED/g")
# Check if the s3 file is RAW image or not
if [ ! -z "$RAW_CHECK" -a "$RAW_CHECK" != " " ]
then
	# Save the file from S3 in the same structure as the S3 object key
	# grep command after pipe is used to supress output
	aws s3 cp "s3://$S3_BUCKET/$S3_KEY" "$S3_KEY" | grep '$$##$$'
	# A medium(50%) resized file of the original file will have the same folder as the original
	# But _MEDIUM will be appended to its file name
	FILE_MEDIUM_SIZED=$(sed "s/.JPG/_MEDIUM.JPG/g" <<< "$S3_KEY")
	FILE_MEDIUM_SIZED=$(sed "s/.jpg/_MEDIUM.jpg/g" <<< "$FILE_MEDIUM_SIZED")
	# Use ImageMagick to create a medium resized file for faster MATLAB processing
	convert -resize 50% "$S3_KEY" "$FILE_MEDIUM_SIZED"
	# Send the downloaded file destination to MATLAB
	echo "$S3_KEY   $FILE_MEDIUM_SIZED   $MESSAGE_RECEIPT_HANDLE   $FINAL_FILE_NAME"
else
	echo "Non raw image -> $S3_KEY"
	aws sqs delete-message --queue-url https://your-queue-aws-url.com --receipt-handle "$MESSAGE_RECEIPT_HANDLE"
fi

