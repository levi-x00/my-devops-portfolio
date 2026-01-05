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
  description = "Instance type for EC2 instances"
  type        = string
  default     = "t3.micro"
}

variable "router_instance_type" {
  description = "Instance type for router instances"
  type        = string
  default     = "t3.micro"
}

variable "cloud_vpc_cidr_block" {
  description = "CIDR block for cloud VPC"
  type        = string
  default     = "10.16.0.0/16"
}

variable "onprem_vpc_cidr_block" {
  description = "CIDR block for on-prem VPC"
  type        = string
  default     = "192.168.8.0/21"
}

variable "router_ami_id" {
  description = "AMI ID for router instances (Ubuntu with strongSwan)"
  type        = string
  default     = "ami-00d8fc944fb171e29"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-05f071c65e32875a8"
}

variable "branch" {
  description = "Branch to pull assets from"
  type        = string
  default     = "master"
}

variable "project_name" {
  description = "Project name used for asset paths"
  type        = string
  default     = "aws-hybrid-bgpvpn"
}

variable "application" {
  description = "Application name"
  type        = string
  default     = "s2s-vpn-bgp"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
