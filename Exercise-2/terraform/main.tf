provider "aws" {
  region = var.region
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  inline_policy {
    name = "lambda-policy"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
            "ec2:CreateTags",
            "iam:TagUser",
            "iam:TagRole",
            "iam:TagGroup",
            "iam:TagPolicy",
            "iam:TagInstanceProfile",
            "iam:TagAccessKey",
            "iam:TagServerCertificate",
            "s3:PutBucketTagging",
            "ec2:CreateTags",
            "elbv2:AddTags"
          ],
          "Effect": "Allow",
          "Resource": "*"
        }
      ]
    })
  }
}


data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir = "${path.module}/../lambda"
  output_path = "${path.module}/../tag_resources.zip"
}

resource "aws_lambda_function" "tag_resources" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "tag_resources"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "tag_resources.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

resource "aws_cloudwatch_event_rule" "resource_creation" {
  name        = "ResourceCreationRule"
  description = "Triggers when an AWS resource is created"
  event_pattern = jsonencode({
    "source": ["aws.ec2","aws.iam","aws.s3","aws.vpc"],
    "detail-type": ["AWS API Call via CloudTrail"],
    "detail": {
      "eventSource": [ "ec2.amazonaws.com","s3.amazonaws.com","iam.amazonaws.com","vpc.amazonaws.com"],
      "eventName": [ { "wildcard": "Create*" }, "RunInstances" ]
    }
  })
}


resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tag_resources.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.resource_creation.arn
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.resource_creation.name
  target_id = "tagResources"
  arn       = aws_lambda_function.tag_resources.arn
}