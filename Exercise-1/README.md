# Terraform Project for AWS Infrastructure

This codebase uses Terraform to manage AWS infrastructure for a web application. The infrastructure includes a VPC with public and private subnets, EC2 instances in an Auto Scaling Group running NGINX, and an Application Load Balancer (ALB) to distribute traffic.


## Execution Steps


1. **Execute Terraform**: Run the following command to initialize the Terraform configuration.
    ```sh
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

