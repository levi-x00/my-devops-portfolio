variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "application" {
  description = "Application name"
  type        = string
  default     = "myapp"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
