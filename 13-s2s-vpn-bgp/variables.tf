variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-3"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "sandbox"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "instance_type" {
  default = "t3.micro"
}

variable "cloud_vpc_cidr_block" {
  default = "10.16.0.0/16"
}
variable "onprem_vpc_cidr_block" {
  default = "10.2.0.0/23"
}
variable "cloud_ami_id" {}
variable "router_ami_id" {}
variable "application" {}
variable "environment" {}
