output "amplify_app_id" {
  description = "The unique ID of the Amplify app"
  value       = aws_amplify_app.main.id
}

output "amplify_app_arn" {
  description = "The ARN of the Amplify app"
  value       = aws_amplify_app.main.arn
}

output "amplify_default_domain" {
  description = "The default domain for the Amplify app"
  value       = aws_amplify_app.main.default_domain
}

output "amplify_app_url" {
  description = "The URL of the Amplify app"
  value       = "https://${var.branch_name}.${aws_amplify_app.main.default_domain}"
}

output "amplify_role_arn" {
  description = "The ARN of the IAM role used by Amplify"
  value       = aws_iam_role.amplify_role.arn
}

output "amplify_branch_name" {
  description = "The name of the deployed branch"
  value       = var.branch_name
}