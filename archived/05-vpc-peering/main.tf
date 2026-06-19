# peering section
resource "aws_vpc_peering_connection" "vpc_peering" {
  peer_vpc_id = aws_vpc.vpc_01.id
  vpc_id      = aws_vpc.vpc_02.id
  # peer_region = var.region
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "peering-vpc01-vpc02"
  }
}
