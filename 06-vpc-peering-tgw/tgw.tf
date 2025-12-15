resource "aws_ec2_transit_gateway" "my_tgw" {
  description = "lab tgw"
  tags = {
    Name = "lab-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attachment01" {
  transit_gateway_id = aws_ec2_transit_gateway.my_tgw.id

  subnet_ids = module.vpc1.private_subnet_ids
  vpc_id     = module.vpc1.vpc_id

  tags = {
    Name = "tgw-vpc01-attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attachment02" {
  transit_gateway_id = aws_ec2_transit_gateway.my_tgw.id

  subnet_ids = module.vpc2.private_subnet_ids
  vpc_id     = module.vpc2.vpc_id

  tags = {
    Name = "tgw-vpc02-attachment"
  }
}
