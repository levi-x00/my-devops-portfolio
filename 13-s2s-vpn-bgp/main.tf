#########################################################################
# VPC Cloud (AWS Side)
#########################################################################
module "cloud_vpc" {
  source = "../modules/vpc"

  vpc_name = "cloud-vpc"

  vpc_cidr_block = "10.16.1.0/24"

  private_subnet_cidra = "10.16.1.0/26"
  private_subnet_cidrb = "10.16.1.64/26"

  public_subnet_cidra = "10.16.1.128/26"
  public_subnet_cidrb = "10.16.1.192/26"

  enable_nat = false
  create_igw = false

  tags = {}
}

#########################################################################
# VPC On-Premises (Simulated)
#########################################################################
module "on_prem_vpc" {
  source   = "../modules/vpc"
  vpc_name = "on-prem-vpc"

  vpc_cidr_block = "192.168.1.0/24"

  private_subnet_cidra = "192.168.1.0/26"
  private_subnet_cidrb = "192.168.1.64/26"

  public_subnet_cidra = "192.168.1.128/26"
  public_subnet_cidrb = "192.168.1.192/26"

  enable_nat = true
  create_igw = true

  tags = {}
}

