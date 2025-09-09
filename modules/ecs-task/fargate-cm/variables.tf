variable "service_name" {}
variable "min_capacity" {}
variable "max_capacity" {}
variable "cpu_target_value" {}
variable "mem_target_value" {}
variable "scaling_policy_type" {
  default = "TargetTrackingScaling"
}
variable "scan_on_push" {
  default = false
}
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
