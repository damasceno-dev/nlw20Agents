variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "app_runner_url" {
  description = "App Runner service URL for the backend API"
  type        = string
  default     = ""
}

variable "github_repository" {
  description = "GitHub repository URL (e.g., https://github.com/user/repo)"
  type        = string
  default     = ""
}

variable "branch_name" {
  description = "Git branch to deploy from"
  type        = string
  default     = "main"
}

variable "environment_variables" {
  description = "Environment variables for the Amplify app"
  type        = map(string)
  default     = {}
}

variable "github_access_token" {
  description = "GitHub personal access token for repository access"
  type        = string
  sensitive   = true
}