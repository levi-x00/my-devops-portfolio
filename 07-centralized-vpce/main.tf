terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
  required_version = ">=1.5.0"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

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

  region = var.aws_region

  public_subnet_cidra = "10.1.1.0/25"
  public_subnet_cidrb = "10.1.1.128/25"

  enable_nat = false
  create_igw = true

  tags = var.tags
}

module "vpc_spoke1" {
  source = "../modules/vpc"

  vpc_name       = "spoke1-vpc"
  vpc_cidr_block = "10.2.0.0/23"

  private_subnet_cidra = "10.2.0.0/25"
  private_subnet_cidrb = "10.2.0.128/25"

  region = var.aws_region

  public_subnet_cidra = "10.2.1.0/25"
  public_subnet_cidrb = "10.2.1.128/25"

  enable_nat = false
  create_igw = true

  tags = var.tags
}

module "vpc_spoke2" {
  source = "../modules/vpc"

  vpc_name       = "spoke2-vpc"
  vpc_cidr_block = "10.3.0.0/23"

  private_subnet_cidra = "10.3.0.0/25"
  private_subnet_cidrb = "10.3.0.128/25"

  region = var.aws_region

  public_subnet_cidra = "10.3.1.0/25"
  public_subnet_cidrb = "10.3.1.128/25"

  enable_nat = false
  create_igw = true

  tags = var.tags
}
