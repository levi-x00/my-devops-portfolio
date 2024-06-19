resource "aws_subnet" "private-1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidra
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.vpc_name}-private-1a"
  }
}

resource "aws_subnet" "private-1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrb
  availability_zone = "${var.region}b"

  tags = {
    "Name" = "${var.vpc_name}-private-1b"
  }
}

resource "aws_subnet" "public-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidra
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.vpc_name}-public-1a"
  }
}

resource "aws_subnet" "public-1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrb
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-1b"
  }
}
