variable "service_name" {
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

variable "retention_days" {
  default = 90
}

variable "memory" {
  default = "2048"
}

variable "cpu" {
  default = "1024"
}

variable "public_domain" {
  default = "456587053760.realhandsonlabs.net"
}

variable "docker_file_path" {
  default = ""
}

variable "port" {
  type    = number
  default = 5000
}

variable "path_pattern" {
  default = "/"
}

variable "cluster_info" {}
variable "network_info" {}
