resource "aws_vpc_endpoint" "vpce" {
  for_each = local.vpc_endpoints
  vpc_id   = aws_vpc.main.id

  service_name      = each.value
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.vpce.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "${each.key}-${var.environment}-vpce"
  }
}
