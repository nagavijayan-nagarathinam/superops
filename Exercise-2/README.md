# AWS Resource Tagging Project

This codebase uses AWS Lambda, CloudTrail, and CloudWatch Events to automatically tag AWS resources created in aws account. The tags include the IAM user ARN of the user who created or updated the resources. 


## Setup and Execution


**Deploy with Terraform**:
    - Use the Terraform configuration to deploy the Lambda function and CloudWatch Event Rule:
    
    sh
    cd superops/Exercise-2/terraform
    terraform init
    terraform plan
    terraform apply



## Project Structure
```
.
├── lambda
│ ├── tag_ec2.py
│ ├── tag_iam.py
│ ├── tag_s3.py
│ ├── tag_vpc.py
│ └── tag_resources.py
└── terraform
  ├── main.tf
  ├── variables.tf
  ├── outputs.tf
  └── .gitignore
```


## Terraform Configuration

### main.tf

Defines the AWS resources needed for the project. This includes:

- **IAM Role**: An IAM role for the Lambda function with permissions to tag resources. The `AWSLambdaBasicExecutionRole` managed policy is attached to provide basic execution permissions.
- **Lambda Function**: Creates the Lambda function using the packaged code.
- **CloudWatch Event Rule**: Defines an event pattern to capture specific CloudTrail events related to resource creation.
- **CloudWatch Event Target**: Links the CloudWatch Event Rule to the Lambda function.
- **Lambda Permission**: Grants CloudWatch Events permission to invoke the Lambda function.



## Lambda Functions

### lambda_handler( tag_resources.py )

This is the main entry point for the Lambda function. It routes CloudTrail events to the appropriate service-specific tagging functions. It extracts relevant details from the CloudTrail event, such as the user ARN and the event name, and logs these details. Based on the event name, it invokes the corresponding function to handle tagging for EC2, IAM, S3, or VPC resources.


This setup ensures that any AWS resources created in the account, including those related to IAM, EC2, S3, and VPC, are automatically tagged using the user ARN who created them. 
