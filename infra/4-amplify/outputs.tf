output "amplify_app_id" {
  value       = module.amplify.amplify_app_id
  description = "The unique ID of the Amplify app"
}

output "amplify_app_arn" {
  value       = module.amplify.amplify_app_arn
  description = "The ARN of the Amplify app"
}

output "amplify_default_domain" {
  value       = module.amplify.amplify_default_domain
  description = "The default domain for the Amplify app"
}

output "amplify_app_url" {
  value       = module.amplify.amplify_app_url
  description = "The URL of the Amplify app"
}