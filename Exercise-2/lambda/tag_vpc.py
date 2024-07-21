import boto3
import logging

logger = logging.getLogger()

def tag_vpc_resources(event, user_arn, event_name):
    client = boto3.client('ec2')

    try:
        if event_name == "CreateVpc":
            logger.info("Tagging VPC")
            tag_vpc(event, user_arn, client)
        elif event_name == "CreateSubnet":
            logger.info("Tagging Subnet")
            tag_subnet(event, user_arn, client)
        elif event_name == "CreateRouteTable":
            logger.info("Tagging Route table")
            tag_route_table(event, user_arn, client)
        elif event_name == "CreateInternetGateway":
            logger.info("Tagging Internet gateway")
            tag_internet_gateway(event, user_arn, client)
        elif event_name == "CreateNatGateway":
            logger.info("Tagging NAT gateway")
            tag_nat_gateway(event, user_arn, client)
        elif event_name == "CreateNetworkAcl":
            logger.info("Tagging Network ACL")
            tag_network_acl(event, user_arn, client)
        else:
            logger.warning("Unhandled VPC event: %s", event_name)
    except Exception as e:
        logger.error("Error Tagging VPC resources: %s", e)

def tag_vpc(event, user_arn, client):
    vpc_id = event['detail']['responseElements']['vpc']['vpcId']
    logger.info("Tagging VPC: %s", vpc_id)
    client.create_tags(
        Resources=[vpc_id],
        Tags=[
            {'Key': 'CreatedBy', 'Value': user_arn},
        ]
    )

def tag_subnet(event, user_arn, client):
    subnet_id = event['detail']['responseElements']['subnet']['subnetId']
    logger.info("Tagging Subnet: %s", subnet_id)
    client.create_tags(
        Resources=[subnet_id],
        Tags=[
            {'Key': 'CreatedBy', 'Value': user_arn},
        ]
    )

def tag_route_table(event, user_arn, client):
    route_table_id = event['detail']['responseElements']['routeTable']['routeTableId']
    logger.info("Tagging Route table: %s", route_table_id)
    client.create_tags(
        Resources=[route_table_id],
        Tags=[
            {'Key': 'CreatedBy', 'Value': user_arn},
        ]
    )

def tag_internet_gateway(event, user_arn, client):
    igw_id = event['detail']['responseElements']['internetGateway']['internetGatewayId']
    logger.info("Tagging Internet gateway: %s", igw_id)
    client.create_tags(
        Resources=[igw_id],
        Tags=[
            {'Key': 'CreatedBy', 'Value': user_arn},
        ]
    )

def tag_nat_gateway(event, user_arn, client):
    nat_gw_id = event['detail']['responseElements']['natGateway']['natGatewayId']
    logger.info("Tagging NAT gateway: %s", nat_gw_id)
    client.create_tags(
        Resources=[nat_gw_id],
        Tags=[
            {'Key': 'CreatedBy', 'Value': user_arn},
        ]
    )

def tag_network_acl(event, user_arn, client):
    acl_id = event['detail']['responseElements']['networkAcl']['networkAclId']
    logger.info("Tagging Network ACL: %s", acl_id)
    client.create_tags(
        Resources=[acl_id],
        Tags=[
            {'Key': 'CreatedBy', 'Value': user_arn},
        ]
    )