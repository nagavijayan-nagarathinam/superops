variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "num_public_subnets" {
  description = "Number of public subnet"
  type        = number
  default     = 2
}

variable "num_private_subnets" {
  description = "Number of private subnet"
  type        = number
  default     = 2
}

variable "num_ips_per_subnet" {
  description = "Min IP count per subnet"
  type        = number
  default     = 80
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "tags" {
  description = "Common tag"
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "example"
    Owner       = "yourname"
  }
}

variable "resource_prefix" {
  description = "Project Name"
  type        = string
  default     = "superops"
}


variable "default_tags" {
  type        = map(string)
  default     = {
    Project     = "SuperOps"
    Owner       = "DevOps"
  }
}

variable "environment" {
    type = string
}