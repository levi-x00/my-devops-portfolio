########################################################################
# default route table
########################################################################
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

########################################################################
# private route table
########################################################################
resource "aws_route_table" "private_rt" {
  count  = var.enable_two_nats == true ? 0 : 1
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table" "private1" {
  count  = var.enable_two_nats == true ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-private1-rt"
  }
}

resource "aws_route" "private1_route" {
  route_table_id = var.enable_two_nats == true ? aws_route_table.private1[0].id : aws_route_table.private_rt[0].id
  nat_gateway_id = aws_nat_gateway.nat1.id

  destination_cidr_block = "0.0.0.0/0"
}


resource "aws_route_table" "private2" {
  count  = var.enable_two_nats == true ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-private2-rt"
  }
}

resource "aws_route" "private2_route" {
  count          = var.enable_two_nats == true ? 1 : 0
  route_table_id = aws_route_table.private2[0].id
  nat_gateway_id = aws_nat_gateway.nat2[0].id

  destination_cidr_block = "0.0.0.0/0"
}

########################################################################
# public route table
########################################################################
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

########################################################################
# subnet association to route table
########################################################################
resource "aws_route_table_association" "private" {
  count          = local.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.enable_two_nats == true ? aws_route_table.private1[0].id : aws_route_table.private_rt[0].id
}

resource "aws_route_table_association" "db" {
  count          = local.az_count
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = var.enable_two_nats == true ? aws_route_table.private1[0].id : aws_route_table.private_rt[0].id
}

resource "aws_route_table_association" "public" {
  count          = local.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
