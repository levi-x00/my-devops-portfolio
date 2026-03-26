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

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "ics-sandbox"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "branch_name" {
  description = "Git branch to trigger the pipeline"
  type        = string
  default     = "main"
}

variable "backend_repository_name" {
  description = "CodeCommit repository name for backend"
  type        = string
}

variable "frontend_repository_name" {
  description = "CodeCommit repository name for frontend"
  type        = string
}

variable "build_timeout" {
  description = "CodeBuild build timeout in minutes"
  type        = number
  default     = 30
}

variable "retention_in_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "tfstate_bucket" {
  description = "S3 bucket for Terraform remote state"
  type        = string
}

variable "network_tfstate_key" {
  description = "S3 key for network stack tfstate"
  type        = string
}

variable "eks_tfstate_key" {
  description = "S3 key for EKS baseline tfstate"
  type        = string
}
