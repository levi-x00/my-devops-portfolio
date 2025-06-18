# ========================= mark default route table ================================
resource "aws_default_route_table" "def-pub-rt" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
    Name = "${var.project_name}-default-public-rt"
  }
}

resource "aws_route" "igw_default_rt" {
  route_table_id = aws_default_route_table.def-pub-rt.id
  gateway_id     = aws_internet_gateway.igw.id

  destination_cidr_block = "0.0.0.0/0"
}

# ========================= custom private route table ==============================
resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-private1-rt"
  }
}

resource "aws_route" "private1_route" {
  route_table_id = aws_route_table.private1.id
  nat_gateway_id = aws_nat_gateway.nat1.id

  destination_cidr_block = "0.0.0.0/0"
}


resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-private2-rt"
  }
}

resource "aws_route" "private2_route" {
  route_table_id = aws_route_table.private2.id
  nat_gateway_id = aws_nat_gateway.nat2.id

  destination_cidr_block = "0.0.0.0/0"
}


# ====================== custom public route table ==============================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route" "public_rt_route" {
  route_table_id = aws_route_table.public.id
  gateway_id     = aws_internet_gateway.igw.id

  destination_cidr_block = "0.0.0.0/0"
}

# ========================= associate the subnets to route table =======================
resource "aws_route_table_association" "private-1a" {
  subnet_id      = aws_subnet.private-1a.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_route_table_association" "private-1b" {
  subnet_id      = aws_subnet.private-1b.id
  route_table_id = aws_route_table.private2.id
}

resource "aws_route_table_association" "db-1a" {
  subnet_id      = aws_subnet.db-1a.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_route_table_association" "db-1b" {
  subnet_id      = aws_subnet.db-1b.id
  route_table_id = aws_route_table.private2.id
}

resource "aws_route_table_association" "public-1a" {
  subnet_id      = aws_subnet.public-1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-1b" {
  subnet_id      = aws_subnet.public-1b.id
  route_table_id = aws_route_table.public.id
}
