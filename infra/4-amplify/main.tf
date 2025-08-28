terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }
  backend "s3" {
    # This will be dynamically configured by the workflow
    # bucket  = "${var.prefix}-terraform-state-unique1029"  
    key     = "4-amplify/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

data "aws_caller_identity" "current" {}
data "terraform_remote_state" "resources" {
  backend = "s3"
  config = {
    # This will be dynamically configured by the workflow to match the prefix
    bucket = "${var.prefix}-terraform-state-unique1029"
    key    = "2-resources/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "amplify" {
  source            = "./modules/amplify"
  prefix            = var.prefix
  account_id        = data.aws_caller_identity.current.account_id
  app_runner_url    = var.app_runner_url
  github_repository = var.github_repository
  branch_name       = var.branch_name
  
  # Environment variables for the Next.js app
  environment_variables = var.app_runner_url != "" ? {
    NEXT_PUBLIC_API_URL = "https://${var.app_runner_url}"
    SWAGGER_URL         = "https://${var.app_runner_url}/swagger/v1/swagger.json"
    NODE_ENV           = "production"
  } : {
    NODE_ENV = "production"
  }
}