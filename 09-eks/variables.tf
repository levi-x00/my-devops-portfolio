variable "environment" {
  default = "dev"
}
variable "application" {
  default = "myapp"
}
variable "region" {
  default = "us-east-1"
}
variable "cluster_name" {
  default = "devops-blueprint-eks"
}
variable "cluster_version" {
  default = "1.30"
}
variable "instance_type" {
  default = "t3.medium"
}
variable "disk_size" {
  default = 16
}
variable "volume_type" {
  default = "gp3"
}
variable "ami_release_version" {
  default = "AL2023_x86_64_STANDARD"
}
