variable "enable_nat" {
  type    = bool
  default = false
}

variable "vpc_name" {
  default = "devops-project"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "profile" {
  type    = string
  default = "default"
}

variable "vpc_cidr_block" {}
variable "private_subnet_cidra" {}
variable "private_subnet_cidrb" {}
variable "public_subnet_cidra" {}
variable "public_subnet_cidrb" {}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "instance_tenancy" {
  type    = string
  default = "default"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "application" {
  type    = string
  default = "devops-blueprint-app"
}

variable "public_subnet_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "availability_zones" {
  type    = list(string)
  default = []
}

variable "map_public_ip_on_launch" {
  type    = bool
  default = true
}
