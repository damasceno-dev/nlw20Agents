terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }
  # Backend configuration is dynamically created by the workflow
  # See .github/workflows/deploy-with-oidc.yml
}

data "aws_caller_identity" "current" {}
data "terraform_remote_state" "resources" {
  backend = "s3"
  config = {
    bucket = "${var.prefix}-terraform-state-unique1029"
    key    = "2-resources/terraform.tfstate"
    region = "us-east-1"
  }
}

# Get the default domain from the Amplify app
locals {
  amplify_default_domain = var.configure_cors ? "${var.prefix}.amplifyapp.com" : ""
}

provider "aws" {
  region = "us-east-1"
  # for github actions or act (ci), its going to take the profile from the aws_id used in the credentials step.
  # Use this if you want to run locally and have aws profiles configured in your machine
  # profile = data.terraform_remote_state.resources.outputs.resources_creator_profile
}

module "app_runner" {
  source              = "./modules/app_runner"
  prefix             = var.prefix
  account_id = data.aws_caller_identity.current.account_id
  repository_name = data.terraform_remote_state.resources.outputs.ecr_repository_name
  repository_arn = data.terraform_remote_state.resources.outputs.ecr_repository_arn
  repository_url = data.terraform_remote_state.resources.outputs.ecr_repository_url
  configure_cors = var.configure_cors
  amplify_url = local.amplify_default_domain
}