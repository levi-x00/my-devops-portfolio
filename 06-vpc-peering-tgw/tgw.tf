resource "aws_ec2_transit_gateway" "my_tgw" {
  description = "demo tgw"
  tags = {
    Name = "my-${var.environment}-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attachment01" {
  transit_gateway_id = aws_ec2_transit_gateway.my_tgw.id

  subnet_ids = [for subnet in aws_subnet.subnets_vpc01 : subnet.id]
  vpc_id     = aws_vpc.vpc_01.id

  tags = {
    Name = "tgw-vpc01-attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attachment02" {
  transit_gateway_id = aws_ec2_transit_gateway.my_tgw.id

  subnet_ids = [for subnet in aws_subnet.subnets_vpc02 : subnet.id]
  vpc_id     = aws_vpc.vpc_02.id

  tags = {
    Name = "tgw-vpc02-attachment"
  }
}
