variable "region" {
  description = "The AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "num_public_subnets" {
  description = "The number of public subnets to create."
  type        = number
  default     = 2
}

variable "num_private_subnets" {
  description = "The number of private subnets to create."
  type        = number
  default     = 2
}

variable "num_ips_per_subnet" {
  description = "The number of IPs per subnet."
  type        = number
  default     = 80
}

variable "instance_type" {
  description = "The type of instance to use."
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the key pair to use for SSH access."
  type        = string
  default     = "dev"
}

variable "private_asg_min_size" {
  description = "The minimum size of the private ASG."
  type        = number
  default     = 1
}

variable "private_asg_max_size" {
  description = "The maximum size of the private ASG."
  type        = number
  default     = 3
}

variable "default_tags" {
  description = "A map of default tags to be applied to all resources."
  type        = map(string)
  default     = {
    Project     = "SuperOps"
    Owner       = "DevOps"
  }
}

variable "resource_prefix" {
  description = "A prefix to add to the name of all resources."
  type        = string
  default     = "superops"
}

variable "environment" {
  type = string
  default = "dev"
}