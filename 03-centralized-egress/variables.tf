variable "region" {
  type    = string
  default = "us-east-1"
}

variable "blackhole_cidrs" {
  default = [
    "192.168.0.0/16",
    "172.16.0.0/12",
    "10.0.0.0/8"
  ]
}

variable "profile" {
  type    = string
  default = "default"
}

variable "egress_cidr_block" {
  type    = string
  default = "10.1.0.0/23"
}

variable "spoke01_cidr_block" {
  type    = string
  default = "10.2.0.0/23"
}

variable "spoke02_cidr_block" {
  type    = string
  default = "10.3.0.0/23"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "application" {
  type    = string
  default = "centralized-egress"
}
