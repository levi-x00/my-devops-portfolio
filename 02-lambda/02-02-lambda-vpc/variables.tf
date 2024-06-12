variable "region" {
  default = "us-east-1"
}

variable "lambda_name" {
  default = "lambda-vpc-test1"
}

variable "environment" {
  default = "dev"
}

variable "tags" {
  default = {
    Environment = "dev"
    Application = "devops-app"
  }
}
