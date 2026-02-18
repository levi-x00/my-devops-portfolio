########################################################################
# private subnets
########################################################################
resource "aws_subnet" "private" {
  count      = local.az_count
  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_subnets[count.index]

  availability_zone = "${var.aws_region}${var.availability_zones[count.index]}"
  tags = {
    Name                                        = "private-${var.availability_zones[count.index]}"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "karpenter.sh/discovery"                    = var.cluster_name
  }
}

########################################################################
# public subnets
########################################################################
resource "aws_subnet" "public" {
  count      = local.az_count
  vpc_id     = aws_vpc.main.id
  cidr_block = local.public_subnets[count.index]

  availability_zone       = "${var.aws_region}${var.availability_zones[count.index]}"
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name                                        = "public-${var.availability_zones[count.index]}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

########################################################################
# db subnets
########################################################################
resource "aws_subnet" "db" {
  count      = local.az_count
  vpc_id     = aws_vpc.main.id
  cidr_block = local.db_subnets[count.index]

  availability_zone       = "${var.aws_region}${var.availability_zones[count.index]}"
  map_public_ip_on_launch = false
  tags = {
    Name = "db-${var.availability_zones[count.index]}"
  }
}
