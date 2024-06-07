# =============================== create elastic ip ===============================
resource "aws_eip" "nat1" {
  tags = {
    Name = "${var.environment}-nat1"
  }
}

resource "aws_eip" "nat2" {
  tags = {
    Name = "${var.environment}-nat2"
  }
}

# =============================== create nat gateway ===============================
resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public-1a.id

  tags = {
    Name = "nat-gw1"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat2" {
  allocation_id = aws_eip.nat2.id
  subnet_id     = aws_subnet.public-1b.id

  tags = {
    Name = "nat-gw2"
  }

  depends_on = [aws_internet_gateway.igw]
}
