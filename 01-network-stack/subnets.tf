########################################################################
# private subnets
########################################################################
resource "aws_subnet" "private-1a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"

  availability_zone = "${var.aws_region}a"
  tags = {
    Name                              = "private-1a"
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery"          = var.cluster_name
  }
}

resource "aws_subnet" "private-1b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  availability_zone = "${var.aws_region}b"
  tags = {
    Name                              = "private-1b"
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery"          = var.cluster_name
  }
}

########################################################################
# public subnets
########################################################################
resource "aws_subnet" "public-1a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/25"

  availability_zone = "${var.aws_region}a"

  map_public_ip_on_launch = true
  tags = {
    Name                     = "public-1a"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public-1b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.128/25"

  availability_zone = "${var.aws_region}b"

  map_public_ip_on_launch = true
  tags = {
    Name                     = "public-1b"
    "kubernetes.io/role/elb" = "1"
  }
}

########################################################################
# db subnets
########################################################################
resource "aws_subnet" "db-1a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/25"

  availability_zone = "${var.aws_region}a"

  map_public_ip_on_launch = true
  tags = {
    Name = "db-1a"
  }
}

resource "aws_subnet" "db-1b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.128/25"

  availability_zone = "${var.aws_region}b"

  map_public_ip_on_launch = true
  tags = {
    Name = "db-1b"
  }
}
