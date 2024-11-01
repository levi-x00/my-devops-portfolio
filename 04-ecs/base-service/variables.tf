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
  default = "main-service"
}

variable "cpu" {
  default = 256
}

variable "memory" {
  default = 512
}

variable "port" {
  default = 5000
}

variable "cw_logs_retention_days" {
  default = 90
}
