output "lambda_function_arn" {
  value = aws_lambda_function.tag_resources.arn
}

output "cloudwatch_event_rule_arn" {
  value = aws_cloudwatch_event_rule.resource_creation.arn
}
