# Output all policy ARNs for attachment in the main module

output "vpc_policy_arn" {
  value       = aws_iam_policy.vpc_policy.arn
  description = "ARN of the VPC management policy"
}

output "rds_policy_arn" {
  value       = aws_iam_policy.rds_policy.arn
  description = "ARN of the RDS and Aurora management policy"
}

output "ecr_policy_arn" {
  value       = aws_iam_policy.ecr_policy.arn
  description = "ARN of the ECR management policy"
}

output "app_runner_policy_arn" {
  value       = aws_iam_policy.app_runner_policy.arn
  description = "ARN of the App Runner management policy"
}

output "iam_policy_arn" {
  value       = aws_iam_policy.iam_policy.arn
  description = "ARN of the IAM management policy for service roles"
}

output "s3_policy_arn" {
  value       = aws_iam_policy.s3_policy.arn
  description = "ARN of the S3 management policy"
}

output "cloudwatch_policy_arn" {
  value       = aws_iam_policy.cloudwatch_policy.arn
  description = "ARN of the CloudWatch Logs policy"
}

output "sqs_policy_arn" {
  value       = aws_iam_policy.sqs_policy.arn
  description = "ARN of the SQS management policy"
}

output "amplify_policy_arn" {
  value       = aws_iam_policy.amplify_policy.arn
  description = "ARN of the Amplify management policy"
}

output "all_policy_arns" {
  value = [
    aws_iam_policy.vpc_policy.arn,
    aws_iam_policy.rds_policy.arn,
    aws_iam_policy.ecr_policy.arn,
    aws_iam_policy.app_runner_policy.arn,
    aws_iam_policy.iam_policy.arn,
    aws_iam_policy.s3_policy.arn,
    aws_iam_policy.cloudwatch_policy.arn,
    aws_iam_policy.sqs_policy.arn,
    aws_iam_policy.amplify_policy.arn
  ]
  description = "List of all policy ARNs created by this module"
}

output "policy_names" {
  value = {
    vpc        = aws_iam_policy.vpc_policy.name
    rds        = aws_iam_policy.rds_policy.name
    ecr        = aws_iam_policy.ecr_policy.name
    app_runner = aws_iam_policy.app_runner_policy.name
    iam        = aws_iam_policy.iam_policy.name
    s3         = aws_iam_policy.s3_policy.name
    cloudwatch = aws_iam_policy.cloudwatch_policy.name
    sqs        = aws_iam_policy.sqs_policy.name
    amplify    = aws_iam_policy.amplify_policy.name
  }
  description = "Map of policy types to their names"
}