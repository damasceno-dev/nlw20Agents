variable "prefix" {
  description = "Prefix for resource names"
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