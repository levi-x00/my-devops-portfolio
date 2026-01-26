variable "project_name" {
  description = "The project name for this terraform vpc"
  default     = ""
}

variable "aws_region" {
  description = "AWS region where the resources will be created"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = ""
}

variable "vpc_cidr_block" {
  description = "The VPC CIDR network"
  type        = string
  default     = ""
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["a", "b"]
}

variable "subnet_newbits" {
  description = "Number of bits to add to VPC CIDR for subnets (e.g., 3 for /27 from /24)"
  type        = number
  default     = 3
}

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
  description = "The application name for this VPC"
  type        = string
  default     = "myapp"
}

variable "map_public_ip_on_launch" {
  type    = bool
  default = true
}

variable "aws_profile" {}
variable "enable_two_nats" {}
