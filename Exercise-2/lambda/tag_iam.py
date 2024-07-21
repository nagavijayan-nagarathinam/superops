import boto3
import logging

logger = logging.getLogger()

def tag_iam_resources(event, user_arn, event_name):
    client = boto3.client('iam')

    try:
        if event_name == "CreateUser":
            logger.info("Tagging IAM user")
            tag_iam_user(event, user_arn, client)
        elif event_name == "CreateRole":
            logger.info("Tagging IAM role")
            tag_iam_role(event, user_arn, client)
        elif event_name == "CreateGroup":
            logger.info("Tagging IAM group")
            tag_iam_group(event, user_arn, client)
        elif event_name == "CreatePolicy":
            logger.info("Tagging IAM policy")
            tag_iam_policy(event, user_arn, client)
        elif event_name == "CreateInstanceProfile":
            logger.info("Tagging IAM instance profile")
            tag_iam_instance_profile(event, user_arn, client)
        elif event_name == "CreateAccessKey":
            logger.info("Tagging IAM access key")
            tag_iam_access_key(event, user_arn, client)
        else:
            logger.warning("Unhandled IAM event: %s", event_name)
    except Exception as e:
        logger.error("Error tagging IAM resources: %s", e)

def tag_iam_user(event, user_arn, client):
    user_name = event['detail']['responseElements']['user']['userName']
    logger.info("Tagging User: %s", user_name)
    client.tag_user(
        UserName=user_name,
        Tags=[
            {'Key': 'CreatedBy', 'Value': user_arn},
        ]
    )

def tag_iam_role(event, user_arn, client):
    role_name = event['detail']['responseElements']['role']['roleName']
    logger.info("Tagging Role: %s", role_name)
    client.tag_role(
        RoleName=role_name,
        Tags=[
            {'Key': 'CreatedBy', 'Value': user_arn},
        ]
    )

def tag_iam_group(event, user_arn, client):
    group_name = event['detail']['responseElements']['group']['groupName']
    logger.info("Tagging Group: %s", group_name)
    client.tag_group(
        GroupName=group_name,
        Tags=[
            {'Key': 'CreatedBy', 'Value': user_arn},
        ]
    )

def tag_iam_policy(event, user_arn, client):
    policy_arn = event['detail']['responseElements']['policy']['arn']
    logger.info("Tagging Policy: %s", policy_arn)
    client.tag_policy(
        PolicyArn=policy_arn,
        Tags=[
            {'Key': 'CreatedBy', 'Value': user_arn},
        ]
    )

def tag_iam_instance_profile(event, user_arn, client):
    instance_profile_name = event['detail']['responseElements']['instanceProfile']['instanceProfileName']
    logger.info("Tagging Instance Profile: %s", instance_profile_name)
    client.tag_instance_profile(
        InstanceProfileName=instance_profile_name,
        Tags=[
            {'Key': 'CreatedBy', 'Value': user_arn},
        ]
    )

def tag_iam_access_key(event, user_arn, client):
    access_key_id = event['detail']['responseElements']['accessKey']['accessKeyId']
    logger.info("Tagging Access Key: %s", access_key_id)
    client.tag_access_key(
        AccessKeyId=access_key_id,
        Tags=[
            {'Key': 'CreatedBy', 'Value': user_arn},
        ]
    )
