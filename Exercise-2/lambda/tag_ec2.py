import boto3
import logging


logger = logging.getLogger()


def tag_ec2_resources(event, user_arn, event_name):
    client = boto3.client('ec2')
    elbv2_client = boto3.client('elbv2')
    autoscaling_client = boto3.client('autoscaling')

    try:
        if event_name == "RunInstances":
            logger.info("Tagging EC2 Instances")
            tag_ec2_instances(event, user_arn, client)
        elif event_name == "CreateImage":
            logger.info("Tagging Images")
            tag_ec2_image(event, user_arn, client)
        elif event_name == "CreateLoadBalancer":
            logger.info("Tagging Loadbalancer")
            tag_elbv2(event, user_arn, elbv2_client)
        elif event_name == "CreateTargetGroup":
            logger.info("Tagging Target Group")
            tag_target_group(event, user_arn, elbv2_client)
        elif event_name == "CreateVolume":
            logger.info("Tagging Volumes")
            tag_ec2_volume(event, user_arn, client)
        elif event_name == "CreateSnapshot":
            logger.info("Tagging Snapshot")
            tag_ec2_snapshot(event, user_arn, client)
        elif event_name == "CreateSecurityGroup":
            logger.info("Tagging Security Groups")
            tag_ec2_security_group(event, user_arn, client)
        elif event_name == "CreateAutoScalingGroup":
            logger.info("Tagging Auto Scaling Group")
            tag_auto_scaling_group(event, user_arn, autoscaling_client)
        else:
            logger.warning("Unhandled EC2 Event %s", event_name)
    except Exception as e:
        logger.error("Error Tagging EC2 Resources: %s", e)


def tag_ec2_instances(event, user_arn, client):
    instances = event['detail']['responseElements']['instancesSet']['items']
    for instance in instances:
        logger.info("Tagging Instance ID: %s", instance['instanceId'])
        client.create_tags(
            Resources=[instance['instanceId']],
            Tags=[
                {'Key': 'CreatedBy', 'Value': user_arn},
            ]
        )

def tag_ec2_image(event, user_arn, client):
    image_id = event['detail']['responseElements']['imageId']
    logger.info("Tagging Image: %s", image_id)
    client.create_tags(
        Resources=[image_id],
        Tags=[
            {'Key': 'CreatedBy', 'Value': user_arn},
        ]
    )

def tag_elbv2(event, user_arn, client):
    lb_arn = event['detail']['responseElements']['loadBalancerArn']
    logger.info("Tagging Load Balancer: %s", lb_arn)
    client.add_tags(
        ResourceArns=[lb_arn],
        Tags=[
            {'Key': 'CreatedBy', 'Value': user_arn},
        ]
    )

def tag_target_group(event, user_arn, client):
    tg_arn = event['detail']['responseElements']['targetGroupArn']
    logger.info("Tagging Target Group: %s", tg_arn)
    client.add_tags(
        ResourceArns=[tg_arn],
        Tags=[
            {'Key': 'CreatedBy', 'Value': user_arn},
        ]
    )

def tag_ec2_volume(event, user_arn, client):
    volume_id = event['detail']['responseElements']['volumeId']
    logger.info("Tagging Volume: %s", volume_id)
    client.create_tags(
        Resources=[volume_id],
        Tags=[
            {'Key': 'CreatedBy', 'Value': user_arn},
        ]
    )

def tag_ec2_snapshot(event, user_arn, client):
    snapshot_id = event['detail']['responseElements']['snapshotId']
    logger.info("Tagging Snapshot: %s", snapshot_id)
    client.create_tags(
        Resources=[snapshot_id],
        Tags=[
            {'Key': 'CreatedBy', 'Value': user_arn},
        ]
    )

def tag_ec2_security_group(event, user_arn, client):
    sg_id = event['detail']['responseElements']['groupId']
    logger.info("Tagging Security Group: %s", sg_id)
    client.create_tags(
        Resources=[sg_id],
        Tags=[
            {'Key': 'CreatedBy', 'Value': user_arn},
        ]
    )

def tag_auto_scaling_group(event, user_arn, client):
    asg_name = event['detail']['requestParameters']['autoScalingGroupName']
    logger.info("Tagging Auto Scaling Group: %s", asg_name)
    client.create_or_update_tags(
        Tags=[
            {
                'ResourceId': asg_name,
                'ResourceType': 'auto-scaling-group',
                'Key': 'CreatedBy',
                'Value': user_arn,
                'PropagateAtLaunch': True
            }
        ]
    )