terraform {
  backend "s3" {
    bucket         = "s3-backend-tfstate-djnf2a8"
    key            = "${var.environment}/centralize-vpce-stack.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodb-lock-table-djnf2a8"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
  required_version = ">=1.5.0"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.environment
      Application = var.application
    }
  }
}

module "vpce" {
  source         = "../modules/vpc"
  vpc_cidr_block = ""

  private_subnet_cidra = ""
  private_subnet_cidrb = ""

  public_subnet_cidra = ""
  public_subnet_cidrb = ""

  enable_nat = false

}

module "vpc_spoke1" {
  source = "../modules/vpc"

  vpc_cidr_block = ""

  private_subnet_cidra = ""
  private_subnet_cidrb = ""

  public_subnet_cidra = ""
  public_subnet_cidrb = ""

  enable_nat = false

}

module "vpc_spoke2" {
  source = "../modules/vpc"

  vpc_cidr_block = ""

  private_subnet_cidra = ""
  private_subnet_cidrb = ""

  public_subnet_cidra = ""
  public_subnet_cidrb = ""

  enable_nat = false

}
