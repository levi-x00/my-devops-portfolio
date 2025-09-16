variable "aws_region" {}
variable "environment" {
  default = "dev"
}

variable "application" {
  default = "devops-blueprint-app"
}

variable "service_name" {
  default = "service-2"
}

variable "cpu" {
  default = 256
}

variable "memory" {
  default = 512
}

variable "cw_logs_retention_days" {
  default = 90
}

variable "port" {
  default = 5002
}

variable "aws_profile" {}
variable "tfstate_bucket" {}
variable "tfstate_network_key" {}
variable "tfstate_ecs_key" {}
