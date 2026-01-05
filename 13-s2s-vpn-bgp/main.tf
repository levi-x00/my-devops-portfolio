#########################################################################
# VPC Cloud (AWS Side)
#########################################################################
module "cloud_vpc" {
  source = "../modules/vpc"

  vpc_name = "cloud-vpc"

  vpc_cidr_block = "10.16.0.0/16"

  private_subnet_cidra = "10.16.32.0/20"
  private_subnet_cidrb = "10.16.96.0/20"

  public_subnet_cidra = "10.16.0.0/20"
  public_subnet_cidrb = "10.16.64.0/20"

  multi_az_nat = false
  enable_nat   = false
  create_igw   = false

  tags = {}
}

#########################################################################
# VPC On-Premises (Simulated)
#########################################################################
module "on_prem_vpc" {
  source   = "../modules/vpc"
  vpc_name = "on-prem-vpc"

  vpc_cidr_block = "192.168.8.0/21"

  private_subnet_cidra = "192.168.10.0/24"
  private_subnet_cidrb = "192.168.11.0/24"

  public_subnet_cidra = "192.168.12.0/24"
  public_subnet_cidrb = "192.168.13.0/24"

  multi_az_nat = false
  enable_nat   = true
  create_igw   = true

  tags = {}
}

