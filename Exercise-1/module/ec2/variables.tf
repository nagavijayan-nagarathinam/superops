variable "aws_region" {
    type = string
}


variable "vpc_id" {
    type = string  
}

variable "public_subnet_ids" {
    type = list(string)
}

variable "private_subnet_ids" {
    type = list(string)  
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "key_name" {
  type = string
}

variable "resource_prefix" {
    type = string
    default = "superops"
}

variable "private_asg_desired_capacity" {
    type = number
    default = 2
}

variable "private_asg_min_size" {
    type = number
    default = 2
}

variable "private_asg_max_size" {
    type = number
    default = 2
}

variable "default_tags" {
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "SuperOps"
    Owner       = "DevOps"
  }
}

variable "environment" {
    type = string
}