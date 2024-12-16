variable "cluster_name" {
  default = "devops-blueprint"
}

variable "region" {
  default = "us-east-1"
}

variable "environment" {
  default = "dev"
}

variable "application" {
  default = "devops-blueprint-app"
}

variable "public_domain" {}
variable "enable_lb_ssl" {}
variable "retention_days" {
  default = 90
}
variable "s3_config_bucket" {}
