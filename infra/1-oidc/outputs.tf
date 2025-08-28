# ========================================
# ROLE OUTPUTS
# ========================================

output "github_deploy_role_arn" {
  value       = aws_iam_role.github_deploy.arn
  description = "ARN of the GitHub deployment role - use this in your workflows"
}

output "github_deploy_role_name" {
  value       = aws_iam_role.github_deploy.name
  description = "Name of the GitHub deployment role"
}

# ========================================
# OIDC PROVIDER OUTPUTS
# ========================================

output "oidc_provider_arn" {
  value       = local.oidc_provider_arn
  description = "ARN of the GitHub OIDC provider"
}

output "oidc_provider_url" {
  value       = "https://token.actions.githubusercontent.com"
  description = "URL of the GitHub OIDC provider"
}

# ========================================
# CONFIGURATION OUTPUTS
# ========================================

output "github_repo_configured" {
  value       = "${var.github_org}/${var.github_repo}"
  description = "GitHub repository configured for OIDC"
}

output "allowed_branch" {
  value       = var.allowed_branch
  description = "Git branch allowed to deploy"
}

output "environment" {
  value       = var.environment
  description = "Environment configured"
}

output "aws_account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS Account ID where resources are deployed"
}

# ========================================
# POLICY OUTPUTS
# ========================================

output "attached_policies" {
  value = module.iam_policies.policy_names
  description = "Map of attached policy names"
}

output "policy_arns" {
  value = module.iam_policies.all_policy_arns
  description = "List of all policy ARNs attached to the role"
}

# ========================================
# WORKFLOW CONFIGURATION OUTPUT
# ========================================

output "github_workflow_config" {
  value = {
    role_arn       = aws_iam_role.github_deploy.arn
    aws_region     = var.aws_region
    aws_account_id = data.aws_caller_identity.current.account_id
    prefix         = var.prefix
  }
  description = "Configuration values for GitHub workflows"
}

# ========================================
# SETUP INSTRUCTIONS OUTPUT
# ========================================

output "setup_complete" {
  value = <<-EOT
    
    ========================================
    ✅ OIDC SETUP COMPLETE!
    ========================================
    
    GitHub Deploy Role ARN:
    ${aws_iam_role.github_deploy.arn}
    
    Repository Configured:
    ${var.github_org}/${var.github_repo}
    
    Policies Attached:
    - VPC and Networking
    - RDS and Aurora
    - ECR
    - App Runner
    - Amplify
    - IAM (for service roles)
    - S3 (state and app buckets)
    - CloudWatch Logs
    - SQS
    
    ========================================
    ⚠️  CRITICAL NEXT STEPS:
    ========================================
    
    1. DELETE the temporary setup user:
       AWS Console → IAM → Users → temp-setup-${var.prefix}-* → Delete
    
    2. DELETE temporary GitHub secrets:
       Settings → Secrets → TEMP_AWS_ACCESS_KEY_ID → Delete
       Settings → Secrets → TEMP_AWS_SECRET_ACCESS_KEY → Delete
    
    3. VERIFY remaining secrets:
       Should only have: DB_PASSWORD, OPENAI_API_KEY
    
    4. UPDATE your workflows to use:
       role-to-assume: ${aws_iam_role.github_deploy.arn}
       aws-region: ${var.aws_region}
    
    ========================================
    YOUR GITHUB ACTIONS NOW HAS SECURE,
    TEMPORARY AWS ACCESS WITH NO STORED
    CREDENTIALS!
    ========================================
  EOT

  depends_on = [
    aws_iam_role_policy_attachment.attach_vpc,
    aws_iam_role_policy_attachment.attach_rds,
    aws_iam_role_policy_attachment.attach_ecr,
    aws_iam_role_policy_attachment.attach_app_runner,
    aws_iam_role_policy_attachment.attach_amplify,
    aws_iam_role_policy_attachment.attach_iam,
    aws_iam_role_policy_attachment.attach_s3,
    aws_iam_role_policy_attachment.attach_cloudwatch,
    aws_iam_role_policy_attachment.attach_sqs
  ]
}