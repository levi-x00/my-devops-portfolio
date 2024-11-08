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

variable "service_domain" {}

variable "retention_days" {
  default = 90
}
