variable "cluster_name" {
  default = "devops-blueprint"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "aws_profile" {}

variable "environment" {
  default = "dev"
}

variable "application" {
  default = "devops-blueprint-app"
}

variable "service_domain" {}

variable "retention_days" {
  default = 90
}

variable "tfstate_bucket" {}
variable "tfstate_key" {}
