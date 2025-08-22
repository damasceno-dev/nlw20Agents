
variable "prefix" {
  description = "Project prefix for resource naming"
  type        = string
  validation {
    condition     = length(var.prefix) <= 10
    error_message = "Prefix must be 10 characters or less to avoid AWS naming limit issues."
  }
}