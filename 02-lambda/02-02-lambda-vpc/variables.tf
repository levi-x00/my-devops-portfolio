variable "region" {
  default = "us-east-1"
}

variable "lambda_name" {
  default = "my-vpc-lambda"
}

variable "tags" {
  default = {
    Environment = "dev"
    Application = "devops-app"
  }
}
