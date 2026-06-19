variable "environment" {
  type    = string
  default = "dev"
}

variable "aws_profile" {}

variable "application" {
  type    = string
  default = "infra-prerequisites"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}
