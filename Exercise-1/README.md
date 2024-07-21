# Terraform Project for AWS Infrastructure

This codebase uses Terraform to manage AWS infrastructure for a web application. The infrastructure includes a VPC with public and private subnets, EC2 instances in an Auto Scaling Group running NGINX, and an Application Load Balancer (ALB) to distribute traffic.

# Modifying Variables
You can modify the variables in the variables.tf file within each environment directory to suit your requirements. Below is an example of variables that can be modified, along with their default values:
```
region:                 The AWS region. Default is ap-south-1.

vpc_cidr:               The CIDR block for the VPC. Default is 10.0.0.0/16.

num_public_subnets:     The number of public subnets to create. Default is 2.

num_private_subnets:    The number of private subnets to create. Default is 2.

num_ips_per_subnet:     The number of IPs per subnet. Default is 80.

instance_type:          The type of instance to use. Default is t2.micro.

key_name:               The name of the key pair to use for SSH access. Default is dev.

private_asg_min_size:   The minimum size of the private ASG. Default is 1.

private_asg_max_size:   The maximum size of the private ASG. Default is 3.

default_tags:           A map of default tags to be applied to all resources. Default is { Project = "SuperOps", Owner = "DevOps" }.

resource_prefix:        A prefix to add to the name of all resources. Default is superops.

environment:            The environment name. Default is dev.
```

## Execution Steps


1. **Execute Terraform**: Run the following command to initialize the Terraform configuration.
    ```
    export AWS_ACCESS_KEY_ID=your_access_key_id

    export AWS_SECRET_ACCESS_KEY=your_secret_access_key

    cd superops/Exercise-1/environment/production

    terraform init

    terraform plan

    terraform apply
    ```

2. **Test the Setup**: Use the ALB DNS output from the Terraform output to curl and get the "hello-world" response.
    ```sh
    curl http://$(terraform output -raw alb_dns)
    ```

## Best Practices Followed

1. **Modularization**: The project is divided into reusable modules (`vpc` and `ec2`), which can be easily managed and scaled.

2. **DRY Principle**: Variables are defined at the top level and passed to modules to avoid repetition and ensure consistency.

3. **Non-overlapping CIDR Blocks**: Subnets are carefully calculated to ensure non-overlapping CIDR blocks within the VPC.

4. **Consistent Tagging**: Resources are tagged consistently using the `merge` function to combine default tags with specific tags for each resource.

5. **IAM Username Tagging**: The IAM username of the user creating or updating the resources is included in the tags for all resources. This is achieved by using the `data "aws_caller_identity"` data source to retrieve the IAM username dynamically.



## Project Structure
```
.
├── environment
│ ├── development
│ │ ├── main.tf
│ │ └── variables.tf
│ └── production
│   ├── main.tf
│   └── variables.tf
├── module
│ ├── ec2
│ │ ├── main.tf
│ │ ├── scripts
│ │ │ └── nginx_setup.sh
│ │ └── variables.tf
│ └── vpc
│   ├── main.tf
│   └── variables.tf
└── notes
```


## Modules

### VPC Module

- **main.tf**: Defines the VPC, public subnets, and private subnets with non-overlapping CIDR blocks and Exports VPC-related outputs.
- **variables.tf**: Defines variables used in the VPC module.

### EC2 Module

- **main.tf**: Defines the EC2 instances, Auto Scaling Group (ASG), and Load Balancer. Exports EC2-related outputs.
- **scripts/nginx_setup.sh**: User data script to set up NGINX on EC2 instances.
- **variables.tf**: Defines variables used in the EC2 module.

## Environments

### Development and Production


Each environment (development and production) has its own directory with specific configuration files:
- **main.tf**: References the VPC and EC2 modules to set up the infrastructure and defines outputs for the environment.
- **variables.tf**: Defines variables specific to the environment.

