variable "environment" {
  type    = string
  default = "prod"
}

variable "ami_id" {
  default = "ami-05f071c65e32875a8"
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "aws_profile" {
  type    = string
  default = ""
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "volume_size" {
  type    = number
  default = 8
}
