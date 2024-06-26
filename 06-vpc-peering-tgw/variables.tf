variable "vpc1_cidr_block" {
  default = "10.0.0.0/24"
}

variable "vpc2_cidr_block" {
  default = "10.1.0.0/24"
}

variable "endpoint_services" {
  type = list(string)
  default = [
    "ssm",
    "ec2messages",
    "ssmmessages"
  ]
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "subnets_vpc01" {
  type = list(object({
    name = string
    cidr = string
  }))
  default = [
    {
      name = "subnet1"
      cidr = "10.0.0.0/25"
    },
    {
      name = "subnet2"
      cidr = "10.0.0.128/25"
    }
  ]
}

variable "subnets_vpc02" {
  type = list(object({
    name = string
    cidr = string
  }))
  default = [
    {
      name = "subnet1"
      cidr = "10.1.0.0/25"
    },
    {
      name = "subnet2"
      cidr = "10.1.0.128/25"
    }
  ]
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
