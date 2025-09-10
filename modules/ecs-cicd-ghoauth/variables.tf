variable "service_name" {}
variable "owner" {
  default = "levi-x00"
}
variable "repo" {
  default = "base-service"
}
variable "oauth_token" {
  default = ""
}
variable "branch_name" {
  default = "master"
}
variable "build_timeout" {
  default = 300
}

variable "retention_days" {
  default = 90
}

variable "s3_bucket_artf" {}
variable "cluster_name" {}
variable "network_info" {}
variable "ecs_info" {}
