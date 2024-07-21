provider "aws" {
    region = var.aws_region

    default_tags {
        tags = var.default_tags
    }
}


data "aws_availability_zones" "available" {}


locals {
  total_subnets = var.num_public_subnets + var.num_private_subnets
  min_subnet_mask = 32 - ceil(log(var.num_ips_per_subnet + 2, 2))
  vpc_mask_size = tonumber(split("/", var.vpc_cidr)[1])
  required_mask_size = local.vpc_mask_size + ceil(log(local.total_subnets, 2))
  subnet_size = max(local.required_mask_size, local.min_subnet_mask )
  newbits = local.subnet_size - local.vpc_mask_size
  azs = data.aws_availability_zones.available.names
  used_azs = slice(local.azs, 0, min(length(local.azs), var.num_private_subnets))
  public_cidr_block  = cidrsubnet(var.vpc_cidr, 2, 0)  
  private_cidr_block = cidrsubnet(var.vpc_cidr, 2, 1)
}


resource "aws_vpc" "superops" {
    cidr_block = var.vpc_cidr 

    tags = merge(
      var.default_tags,
      { Name = "${var.resource_prefix}-vpc-${var.environment}" }
    )


}

resource "aws_eip" "superops" {
    count = length(local.used_azs)
    tags = merge(
      var.default_tags,
      { Name = "${var.resource_prefix}-nat-eip-${element(local.used_azs, count.index)}-${var.environment}" }
    )   
}

resource "aws_internet_gateway" "superops" {
    vpc_id = aws_vpc.superops.id
    tags = merge(
      var.default_tags,
      { Name = "${var.resource_prefix}-igw-${var.environment}" }
    )
}

resource "aws_subnet" "superops_public" {
    count = var.num_public_subnets
    vpc_id = aws_vpc.superops.id
    cidr_block = cidrsubnet(local.public_cidr_block, local.newbits, count.index)
    availability_zone = element(local.azs, count.index % length(local.azs))
    map_public_ip_on_launch = true
    tags = merge( var.default_tags,{ 
        Name = "${var.resource_prefix}-pub-${element(local.azs, count.index % length(local.azs))}-${count.index}-${var.environment}",
        AZ = element(local.azs, count.index % length(local.azs))
        }
    )
}

resource "aws_subnet" "superops_private" {
    count = var.num_private_subnets
    vpc_id = aws_vpc.superops.id
    cidr_block = cidrsubnet(local.private_cidr_block, local.newbits, count.index)
    availability_zone = element(local.azs, count.index % length(local.azs))
    tags = merge( var.default_tags,{ 
        Name = "${var.resource_prefix}-pvt-${element(local.azs, count.index % length(local.azs))}-${count.index}-${var.environment}"
        AZ = element(local.azs, count.index % length(local.azs))
        }
    )
}

resource "aws_nat_gateway" "superops" {
    count = length(local.used_azs)
    allocation_id = aws_eip.superops[count.index].id
    subnet_id = element(aws_subnet.superops_public.*.id, count.index % var.num_public_subnets )
    tags = merge( var.default_tags,{ 
        Name = "${var.resource_prefix}-nat-${element(local.used_azs, count.index % var.num_public_subnets)}-${var.environment}",
        AZ = element(local.used_azs, count.index % var.num_public_subnets )
        }
    )
}

resource "aws_route_table" "superops_public" {
    vpc_id = aws_vpc.superops.id    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.superops.id
    }
    tags = merge( var.default_tags, { Name = "${var.resource_prefix}-public-route-table"} )
}

resource "aws_route_table_association" "superops_public" {
    count = var.num_public_subnets
    subnet_id = aws_subnet.superops_public[count.index].id
    route_table_id = aws_route_table.superops_public.id
}

resource "aws_route_table" "superops_private" {
    count = length(local.used_azs)
    vpc_id = aws_vpc.superops.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.superops[count.index].id
    }
  
    tags = merge( var.default_tags,{ 
        Name = "${var.resource_prefix}-pvt-route-${element(local.used_azs, count.index)}-${var.environment}",
        AZ = element(local.used_azs, count.index)
        }
    )

}

resource "aws_route_table_association" "superops_private" {
    count = var.num_private_subnets
    subnet_id = aws_subnet.superops_private[count.index].id
    route_table_id = element(aws_route_table.superops_private.*.id, count.index % length(local.used_azs))
}


output "public_subnet_ids" {
    value = aws_subnet.superops_public.*.id
}

output "private_subnet_ids" {
    value = aws_subnet.superops_private.*.id
  
}

output "vpc_id" {
    value = aws_vpc.superops.id
}