terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }
  backend "s3" {
    bucket  = "agents-terraform-state-unique1029"  # Must match the bucket created in 1-admin
    key     = "2-resources/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}


provider "aws" {
  region = "us-east-1"
  # for github actions or act (ci), its going to take the profile from the aws_id used in the credentials step. 
  # Use this if you want to run locally and have aws profiles configured in your machine 
  # profile = var.resource_creator_profile
}

module "vpc" {
  source         = "./modules/vpc"
  prefix         = var.prefix
  vpc_cidr_block = var.vpc_cidr_block
}

module "aurora" {
  source      = "./modules/aurora"
  prefix      = var.prefix
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.subnet_ids
  db_name     = var.prefix
  db_username = "postgres"
  db_password = var.db_password
}
module "ecr" {
  source = "./modules/ecr"
  prefix = var.prefix
}
# module "s3" {
#   source = "./modules/s3"
#   prefix = var.prefix
# }
# 
# module "sqs" {
#   source = "./modules/sqs"
#   prefix                       = var.prefix
#   delay_seconds                = 0
#   message_retention_seconds    = 345600
#   visibility_timeout_seconds   = 30
#   receive_wait_time_seconds    = 10
#   max_receive_count            = 5
#   dlq_message_retention_seconds = 1209600
# }
