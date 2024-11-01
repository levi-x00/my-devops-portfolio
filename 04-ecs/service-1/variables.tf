variable "region" {
  default = "us-east-1"
}

variable "environment" {
  default = "dev"
}

variable "application" {
  default = "devops-blueprint-app"
}

variable "service_name" {
  default = "service-1"
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
  default = 5001
}
