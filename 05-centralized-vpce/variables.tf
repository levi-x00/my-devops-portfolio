variable "environment" {
  default = "dev"
}

variable "application" {
  default = "devops-app"
}

variable "region" {
  default = "us-east-1"
}

variable "tags" {
  default = {
    environment = "dev"
    application = "devops-app"
  }
}

variable "vpc_spoke1_cidr" {
  default = "10.2.0.0/23"
}

variable "vpc_spoke2_cidr" {
  default = "10.3.0.0/23"
}

variable "vpc_vpce_cidr" {
  default = "10.1.0.0/23"
}
