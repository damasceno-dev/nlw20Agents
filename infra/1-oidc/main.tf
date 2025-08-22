/*
#######################################################################
# GITHUB OIDC SETUP - ZERO AWS CREDENTIALS IN GITHUB
#######################################################################

This Terraform configuration establishes a trust relationship between
GitHub Actions and AWS, eliminating the need for storing AWS credentials.

ARCHITECTURE:
  GitHub Actions → OIDC Token → AWS STS → Temporary Credentials (1hr) → Deploy

📚 COMPLETE SETUP INSTRUCTIONS:
See README.md in the repository root for detailed step-by-step instructions
on how to set up this full-stack project with OIDC authentication.

The README.md contains:
- Prerequisites and AWS setup
- Local configuration steps  
- GitHub secrets preparation
- OIDC workflow execution
- Security cleanup procedures
- Troubleshooting guide

#######################################################################
# TERRAFORM CONFIGURATION
#######################################################################
*/

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "agents-terraform-state-unique1029"  # Must match bucket from Step 1
    key     = "1-oidc/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    # Optional: Add DynamoDB table for state locking
    # dynamodb_table = "agents-terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.prefix
      ManagedBy   = "Terraform"
      Environment = var.environment
      Repository  = "${var.github_org}/${var.github_repo}"
    }
  }
}

# ========================================
# DATA SOURCES
# ========================================

# Check if OIDC provider already exists
data "aws_iam_openid_connect_providers" "existing" {}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# ========================================
# LOCALS
# ========================================

locals {
  # Construct role name
  github_role_name = "${var.prefix}-github-deploy-role"

  # Use the created OIDC provider ARN directly
  oidc_provider_arn = aws_iam_openid_connect_provider.github.arn

  # Tags for all resources
  common_tags = {
    Project     = var.prefix
    ManagedBy   = "Terraform"
    Environment = var.environment
    Repository  = "${var.github_org}/${var.github_repo}"
    OIDC        = "true"
  }
}

# ========================================
# GITHUB OIDC PROVIDER (SIMPLIFIED)
# ========================================

# Create OIDC provider - use import if it already exists
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  # GitHub's OIDC thumbprints (these rarely change)
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = merge(local.common_tags, {
    Name = "github-oidc-provider"
  })
}

# ========================================
# GITHUB DEPLOYMENT ROLE
# ========================================

resource "aws_iam_role" "github_deploy" {
  name               = local.github_role_name
  description        = "Role for GitHub Actions to deploy ${var.prefix} infrastructure"
  max_session_duration = var.max_session_duration

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:${var.github_org}/${var.github_repo}:*",
              "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${var.allowed_branch}",
              "repo:${var.github_org}/${var.github_repo}:environment:${var.environment}"
            ]
          }
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = local.github_role_name
  })
}

# ========================================
# IAM POLICIES MODULE
# ========================================

module "iam_policies" {
  source = "./modules/iam-policies"

  prefix = var.prefix
}

# ========================================
# ATTACH POLICIES TO ROLE
# ========================================

# Attach all policies from the module to the GitHub role
resource "aws_iam_role_policy_attachment" "attach_vpc" {
  role       = aws_iam_role.github_deploy.name
  policy_arn = module.iam_policies.vpc_policy_arn
}

resource "aws_iam_role_policy_attachment" "attach_rds" {
  role       = aws_iam_role.github_deploy.name
  policy_arn = module.iam_policies.rds_policy_arn
}

resource "aws_iam_role_policy_attachment" "attach_ecr" {
  role       = aws_iam_role.github_deploy.name
  policy_arn = module.iam_policies.ecr_policy_arn
}

resource "aws_iam_role_policy_attachment" "attach_app_runner" {
  role       = aws_iam_role.github_deploy.name
  policy_arn = module.iam_policies.app_runner_policy_arn
}

resource "aws_iam_role_policy_attachment" "attach_iam" {
  role       = aws_iam_role.github_deploy.name
  policy_arn = module.iam_policies.iam_policy_arn
}

resource "aws_iam_role_policy_attachment" "attach_s3" {
  role       = aws_iam_role.github_deploy.name
  policy_arn = module.iam_policies.s3_policy_arn
}

resource "aws_iam_role_policy_attachment" "attach_cloudwatch" {
  role       = aws_iam_role.github_deploy.name
  policy_arn = module.iam_policies.cloudwatch_policy_arn
}

resource "aws_iam_role_policy_attachment" "attach_sqs" {
  role       = aws_iam_role.github_deploy.name
  policy_arn = module.iam_policies.sqs_policy_arn
}