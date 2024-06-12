variable "lambda_name" {
  type    = string
  default = ""
}

variable "environment" {
  default = "dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "profile" {
  type    = string
  default = "default"
}

variable "runtime" {
  type    = string
  default = "python3.9"
}

variable "timeout" {
  default = 30
}

variable "memory_size" {
  default = 256
}

variable "handler" {
  default = "lambda_function.lambda_handler"
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "source_dir" {
  description = "source of the lambda python code and the dependencies"
  default     = ""
}

variable "output_dir" {
  description = "output dir of zip file lambda function"
  default     = ""
}

variable "application" {
  default = "devops-app"
}

variable "lambda_inline_policy" {}
variable "tags" {}

variable "retention_in_days" {
  default = 90
}
