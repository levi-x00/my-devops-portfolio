variable "environment" {
  default = "dev"
}
variable "application" {
  default = "myapp"
}
variable "aws_region" {
  default = "us-east-1"
}
variable "aws_profile" {
  default = "sandbox"
}
variable "cluster_name" {
  default = "devops-blueprint-eks"
}
variable "cluster_version" {
  default = "1.33"
}
variable "retention_in_days" {
  default = 30
}
variable "instance_type" {
  default = "t3.medium"
}
variable "volume_size" {
  default = 20
}
variable "volume_type" {
  default = "gp3"
}
variable "ami_release_version" {
  default = "AL2023_x86_64_STANDARD"
}

variable "eks_cluster_cidr" {
  default = "172.20.0.0/16"
}

variable "cluster_dns_ip" {
  default = "172.20.0.10"
}
variable "instance_types" {
  default = ["t3.medium"]
}
variable "tfstate_bucket" {}
variable "tfstate_key" {}
