# the prefix is coming from the previous step
variable "prefix" {}
variable "repository_name" {}
variable "repository_arn" {}
variable "repository_url" {}
variable "account_id" {}

variable "configure_cors" {
  description = "Whether to enable CORS configuration (handled by GitHub Actions)"
  type        = bool
  default     = false
}

variable "amplify_url" {
  description = "Amplify app URL for CORS configuration (used by GitHub Actions)"
  type        = string
  default     = ""
}