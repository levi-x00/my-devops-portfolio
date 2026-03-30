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

variable "argocd_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "7.8.23"
}

variable "argo_rollouts_version" {
  description = "Argo Rollouts Helm chart version"
  type        = string
  default     = "2.39.5"
}

variable "gitops_repository_name" {
  description = "CodeCommit repository name for GitOps manifests"
  type        = string
  default     = "gitops-repo"
}

variable "git_user_email" {
  description = "Git user email for initial commit"
  type        = string
}

variable "git_user_name" {
  description = "Git user name for initial commit"
  type        = string
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
