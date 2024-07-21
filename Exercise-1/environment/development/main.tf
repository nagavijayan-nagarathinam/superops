provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  iam_username = split("/", data.aws_caller_identity.current.arn)[1]

  merged_tags = merge(
    var.default_tags,
    { Environment = var.environment, CreatedBy = local.iam_username }
  )
}

output "alb_dns" {
    value = module.ec2.alb_dns
}


module "vpc" {
  source = "../../module/vpc"
  vpc_cidr = var.vpc_cidr
  num_public_subnets  = var.num_public_subnets
  num_ips_per_subnet = var.num_ips_per_subnet
  num_private_subnets = var.num_private_subnets
  aws_region = var.region
  default_tags = local.merged_tags
  resource_prefix = var.resource_prefix
  environment = var.environment 
}

module "ec2" {
  source = "../../module/ec2"
  aws_region = var.region
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  instance_type = var.instance_type
  key_name = var.key_name
  private_asg_min_size = var.private_asg_min_size
  private_asg_max_size = var.private_asg_max_size
  default_tags = local.merged_tags
  resource_prefix = var.resource_prefix
  environment = var.environment 
}


