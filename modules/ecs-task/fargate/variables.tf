variable "service_name" {}
variable "min_capacity" {}
variable "max_capacity" {}
variable "target_value" {}
variable "retention_days" {
  default = 90
}

variable "memory" {}
variable "cpu" {}
variable "docker_file_path" {}

variable "port" {
  type    = number
  default = 5000
}

variable "path_pattern" {
  default = "/"
}
variable "cluster_info" {}
variable "network_info" {}
variable "listener_arn" {}
variable "lb_sg_id" {}
