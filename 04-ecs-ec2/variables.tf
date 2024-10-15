variable "cluster_name" {
  default = "devops-blueprint"
}

variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.small"
}

variable "environment" {
  default = "dev"
}

variable "application" {
  default = "devops-blueprint-app"
}

variable "retention_days" {
  default = 90
}

variable "volume_size" {
  default = 16
}

variable "service_domain" { default = "590184080325.realhandsonlabs.net" }
variable "min_size" { default = 1 }
variable "max_size" { default = 1 }
variable "desired_capacity" { default = 1 }
