variable "lambda_name" {
  type    = string
  default = ""
}

variable "function_name" {
  default = ""
}

variable "environment" {
  default = "dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "timeout" {
  default = 30
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "application" {
  default = "devops-app"
}

variable "lambda_inline_policy" {}
variable "tags" {}
variable "source_dir" {}
variable "memory_size" {}
variable "retention_in_days" {
  default = 90
}
