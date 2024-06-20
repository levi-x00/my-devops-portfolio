# ========================= mark default route table ================================
resource "aws_default_route_table" "def-pub-rt" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-default-public-rt"
  }
}

# ========================= custom private route table ==============================
resource "aws_route_table" "private" {
  count  = var.enable_nat == true ? 0 : 1
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

resource "aws_route_table" "private1" {
  count  = var.enable_nat == true ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-private1-rt"
  }
}

resource "aws_route" "nat1" {
  count          = var.enable_nat == true ? 1 : 0
  route_table_id = aws_route_table.private1[0].id

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat1[0].id
}

resource "aws_route_table" "private2" {
  count  = var.enable_nat == true ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-private2-rt"
  }
}

resource "aws_route" "nat2" {
  count          = var.enable_nat == true ? 1 : 0
  route_table_id = aws_route_table.private2[0].id

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat2[0].id
}

# ====================== custom public route table ==============================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# ========================= associate the subnets to route table =======================
resource "aws_route_table_association" "private-1a" {
  count          = var.enable_nat == true ? 1 : 0
  subnet_id      = aws_subnet.private-1a.id
  route_table_id = aws_route_table.private1[0].id
}

resource "aws_route_table_association" "private-1b" {
  count          = var.enable_nat == true ? 1 : 0
  subnet_id      = aws_subnet.private-1b.id
  route_table_id = aws_route_table.private2[0].id
}

resource "aws_route_table_association" "public-1a" {
  subnet_id      = aws_subnet.public-1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-1b" {
  subnet_id      = aws_subnet.public-1b.id
  route_table_id = aws_route_table.public.id
}
