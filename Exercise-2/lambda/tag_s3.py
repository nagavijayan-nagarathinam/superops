import boto3
import logging

logger = logging.getLogger()

def tag_s3_resources(event, user_arn, event_name):
    client = boto3.client('s3')

    try:
        if event_name == "CreateBucket":
            logger.info("Tagging S3 bucket")
            tag_s3_bucket(event, user_arn, client)
        else:
            logger.warning("Unhandled S3 event: %s", event_name)
    except Exception as e:
        logger.error("Error Taggging S3 resources: %s", e)

def tag_s3_bucket(event, user_arn, client):
    bucket_name = event['detail']['requestParameters']['bucketName']
    logger.info("Tagging Bucket: %s", bucket_name)
    client.put_bucket_tagging(
        Bucket=bucket_name,
        Tagging={
            'TagSet': [
                {'Key': 'CreatedBy', 'Value': user_arn},
            ]
        }
    )
