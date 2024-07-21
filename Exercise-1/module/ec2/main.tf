provider "aws" {
    region = var.aws_region

    default_tags {
        tags = var.default_tags
    }
}

data "aws_availability_zones" "available" {}

data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}




resource "aws_key_pair" "superops" {
    key_name = var.key_name
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "public" {
    name = "${var.resource_prefix}-pub-sg-${var.environment}"
    vpc_id = var.vpc_id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = var.default_tags
}


resource "aws_security_group" "private" {
    name = "${var.resource_prefix}-pvt-sg-${var.environment}"
    vpc_id = var.vpc_id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.public.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = var.default_tags
}



resource "aws_launch_template" "private" {
    name = "${var.resource_prefix}-pvt-lt-${var.environment}"
    image_id = data.aws_ami.amzn2.id
    instance_type = var.instance_type
    key_name = aws_key_pair.superops.key_name

    network_interfaces {
      security_groups = [aws_security_group.private.id]
    }
  
    lifecycle {
      create_before_destroy = true
    }

    user_data = filebase64("${path.module}/scripts/nginx_setup.sh")

    tags = var.default_tags
}



resource "aws_autoscaling_group" "private" {
    desired_capacity = var.private_asg_desired_capacity
    min_size = var.private_asg_min_size
    max_size = var.private_asg_max_size
    vpc_zone_identifier = var.private_subnet_ids
    launch_template {
      id = aws_launch_template.private.id
      version = "$Latest"
    }

    tag  {
        key = "Name" 
        value = "${var.resource_prefix}-pvt-asg-${var.environment}"
        propagate_at_launch = true
    }
    
}


resource "aws_lb" "public" {
    name = "${var.resource_prefix}-pub-alb-${var.environment}"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.public.id]
    subnets = var.public_subnet_ids
    tags = merge(
      var.default_tags,
      { Name = "${var.resource_prefix}-pub-alb-${var.environment}" }
    )
}


resource "aws_lb_target_group" "public" {
    name = "${var.resource_prefix}-http-tg-${var.environment}"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc_id

    health_check {
      interval = 10
      path = "/"
      timeout = 5
      healthy_threshold = 2
      unhealthy_threshold = 2
      matcher = "200-299"
    }

    tags = merge(
      var.default_tags,
      { Name = "${var.resource_prefix}-http-tg-${var.environment}" }
    )

  
}


resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.public.arn
    port = "80"
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.public.arn
    }
}


resource "aws_autoscaling_attachment" "asg_attachment" {
    autoscaling_group_name = aws_autoscaling_group.private.name
    lb_target_group_arn = aws_lb_target_group.public.arn 
}


output "alb_dns" {
  value = aws_lb.public.dns_name
}