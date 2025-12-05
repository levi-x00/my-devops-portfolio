#########################################################################
# VPC Cloud
#########################################################################
module "cloud_vpc" {
  source = "../modules/vpc"

  vpc_name = "cloud-vpc"

  vpc_cidr_block = var.cloud_vpc_cidr_block

  private_subnet_cidra = "10.1.0.0/25"
  private_subnet_cidrb = "10.1.0.128/25"

  public_subnet_cidra = "10.1.1.0/25"
  public_subnet_cidrb = "10.1.1.128/25"

  enable_nat = false
  create_igw = true

  tags = var.tags
}

#########################################################################
# VPC On-Premises
#########################################################################
module "on_prem_vpc" {
  source   = "../modules/vpc"
  vpc_name = "on-prem-vpc"

  vpc_cidr_block = var.onprem_vpc_cidr_block

  private_subnet_cidra = "10.2.0.0/25"
  private_subnet_cidrb = "10.2.0.128/25"

  public_subnet_cidra = "10.2.1.0/25"
  public_subnet_cidrb = "10.2.1.128/25"

  enable_nat = true
  create_igw = true

  tags = var.tags
}

