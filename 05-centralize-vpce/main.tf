module "vpce" {
  source         = "../modules/vpc"
  vpc_cidr_block = ""

  private_subnet_cidra = ""
  private_subnet_cidrb = ""

  public_subnet_cidra = ""
  public_subnet_cidrb = ""

}

module "spoke1" {
  source = "../modules/vpc"

  vpc_cidr_block = ""

  private_subnet_cidra = ""
  private_subnet_cidrb = ""

  public_subnet_cidra = ""
  public_subnet_cidrb = ""

}

module "spoke2" {
  source = "../modules/vpc"

  vpc_cidr_block = ""

  private_subnet_cidra = ""
  private_subnet_cidrb = ""

  public_subnet_cidra = ""
  public_subnet_cidrb = ""

}
