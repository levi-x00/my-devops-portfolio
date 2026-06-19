module "egress_vpc" {
  source = "../modules/vpc"

  vpc_name       = "egress-vpc"
  vpc_cidr_block = var.egress_cidr_block

  private_subnet_cidra = "10.1.0.0/25"
  private_subnet_cidrb = "10.1.0.128/25"

  public_subnet_cidra = "10.1.1.0/25"
  public_subnet_cidrb = "10.1.1.128/25"

  enable_nat = true
  create_igw = true

  tags = local.tags
}

module "spoke1_vpc" {
  source = "../modules/vpc"

  vpc_name       = "spoke1-vpc"
  vpc_cidr_block = var.spoke01_cidr_block

  private_subnet_cidra = "10.2.0.0/25"
  private_subnet_cidrb = "10.2.0.128/25"

  public_subnet_cidra = "10.2.1.0/25"
  public_subnet_cidrb = "10.2.1.128/25"

  enable_nat = false
  create_igw = false

  tags = local.tags
}

module "spoke2_vpc" {
  source = "../modules/vpc"

  vpc_name       = "spoke2-vpc"
  vpc_cidr_block = var.spoke02_cidr_block

  private_subnet_cidra = "10.3.0.0/25"
  private_subnet_cidrb = "10.3.0.128/25"

  public_subnet_cidra = "10.3.1.0/25"
  public_subnet_cidrb = "10.3.1.128/25"

  enable_nat = false
  create_igw = false

  tags = local.tags
}
