variable "service_name" {
  default = ""
}

variable "build_timeout" {
  default = 300
}

variable "retention_days" {
  default = 90
}

variable "s3_bucket_artf" {}
variable "repository_name" {}
variable "cluster_name" {}
variable "network_info" {}
variable "ecs_info" {}
