import json, logging
from tag_ec2 import tag_ec2_resources
from tag_iam import tag_iam_resources
from tag_s3 import tag_s3_resources
from tag_vpc import tag_vpc_resources

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()


def lambda_handler(event, context):
    logger.info("Received event: %s", event)

    try:
        user_arn = event['detail']['userIdentity']['arn']
        event_name = event['detail']['eventName']
        logger.info("%s %s", user_arn, event_name  )
    except KeyError as e:
        logger.error(e)
        return e

    try:
        if event_name in ["RunInstances", "CreateImage", "CreateLoadBalancer", "CreateTargetGroup", "CreateVolume", "CreateSnapshot", "CreateSecurityGroup"]:
            tag_ec2_resources(event, user_arn, event_name)
        elif event_name in ["CreateUser", "CreateRole", "CreateGroup", "CreatePolicy", "CreateInstanceProfile", "CreateAccessKey", "UploadServerCertificate"]:
            tag_iam_resources(event, user_arn, event_name)
        elif event_name == "CreateBucket":
            tag_s3_resources(event, user_arn, event_name)
        elif event_name in ["CreateVpc", "CreateSubnet", "CreateRouteTable", "CreateInternetGateway", "CreateNatGateway", "CreateNetworkAcl"]:
            tag_vpc_resources(event, user_arn, event_name)
        else:
            logger.warning("Unhandled event: %s", event_name)
    except Exception as e:
        logger.error("Error processing event: %s", e)
        return e
    
    return {
        'statusCode': 200,
        'body': json.dumps('Resource tagged successfully!')
    }