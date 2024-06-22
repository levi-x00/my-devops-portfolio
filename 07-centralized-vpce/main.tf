terraform {
  # backend "s3" {
  #   bucket         = "s3-backend-tfstate-djnf2a8"
  #   key            = "${var.environment}/centralize-vpce-stack.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "dynamodb-lock-table-djnf2a8"
  # }

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
    tags = var.tags
  }
}

module "vpc_vpce" {
  source = "../modules/vpc"

  vpc_name       = "vpce-vpc"
  vpc_cidr_block = "10.1.0.0/23"

  private_subnet_cidra = "10.1.0.0/25"
  private_subnet_cidrb = "10.1.0.128/25"

  public_subnet_cidra = "10.1.1.0/25"
  public_subnet_cidrb = "10.1.1.128/25"

  enable_nat = false
  tags       = var.tags
}

module "vpc_spoke1" {
  source = "../modules/vpc"

  vpc_name       = "spoke1-vpc"
  vpc_cidr_block = "10.2.0.0/23"

  private_subnet_cidra = "10.2.0.0/25"
  private_subnet_cidrb = "10.2.0.128/25"

  public_subnet_cidra = "10.2.1.0/25"
  public_subnet_cidrb = "10.2.1.128/25"

  enable_nat = false
  tags       = var.tags
}

module "vpc_spoke2" {
  source = "../modules/vpc"

  vpc_name       = "spoke2-vpc"
  vpc_cidr_block = "10.3.0.0/23"

  private_subnet_cidra = "10.3.0.0/25"
  private_subnet_cidrb = "10.3.0.128/25"

  public_subnet_cidra = "10.3.1.0/25"
  public_subnet_cidrb = "10.3.1.128/25"

  enable_nat = false
  tags       = var.tags
}
