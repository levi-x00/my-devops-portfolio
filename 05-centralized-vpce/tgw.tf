resource "aws_ec2_transit_gateway" "mytgw" {
  description = "centralize vpce demo"
  tags = {
    Name = "vpce-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "central_vpce" {
  subnet_ids         = module.vpc_vpce.public_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.mytgw.id
  vpc_id             = module.vpc_vpce.vpc_id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke1" {
  subnet_ids         = module.vpc_spoke1.public_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.mytgw.id
  vpc_id             = module.vpc_spoke1.vpc_id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke2" {
  subnet_ids         = module.vpc_spoke2.public_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.mytgw.id
  vpc_id             = module.vpc_spoke2.vpc_id
}
