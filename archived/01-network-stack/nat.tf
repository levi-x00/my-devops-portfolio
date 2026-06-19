########################################################################
# create elastic ip
########################################################################
resource "aws_eip" "nat1" {
  tags = {
    Name = "${var.project_name}-nat1"
  }
}

resource "aws_eip" "nat2" {
  count = var.enable_two_nats == true ? 1 : 0
  tags = {
    Name = "${var.project_name}-nat2"
  }
}

########################################################################
# create nat gateway
########################################################################
resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-nat-gw1"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat2" {
  count         = var.enable_two_nats == true ? 1 : 0
  allocation_id = aws_eip.nat2[0].id
  subnet_id     = aws_subnet.public[1].id

  tags = {
    Name = "${var.project_name}-nat-gw2"
  }

  depends_on = [aws_internet_gateway.igw]
}
