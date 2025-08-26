# ========================================
# REQUIRED VARIABLES
# ========================================

variable "github_org" {
  description = "GitHub organization or username"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "prefix" {
  description = "Project prefix for resource naming"
  type        = string
  validation {
    condition     = length(var.prefix) <= 10
    error_message = "Prefix must be 10 characters or less to avoid AWS naming limit issues."
  }
}

# ========================================
# OPTIONAL VARIABLES WITH DEFAULTS
# ========================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "allowed_branch" {
  description = "Git branch allowed to assume the role"
  type        = string
  default     = "main"
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds for the role (1-12 hours)"
  type        = number
  default     = 3600  # 1 hour
  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "Session duration must be between 3600 (1 hour) and 43200 (12 hours) seconds."
  }
}

variable "aws_account_id" {
  description = "AWS Account ID (optional, will be auto-detected if not provided)"
  type        = string
  default     = ""
}

# ========================================
# OIDC DETECTION VARIABLES
# ========================================

variable "oidc_provider_exists" {
  description = "Whether OIDC provider already exists in the AWS account"
  type        = bool
  default     = false
}

variable "existing_oidc_provider_arn" {
  description = "ARN of existing OIDC provider (if it exists)"
  type        = string
  default     = ""
}