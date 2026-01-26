resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    var.enable_two_nats ? [aws_route_table.private1[0].id, aws_route_table.private2[0].id] : [aws_route_table.private_rt[0].id],
    [aws_route_table.public.id]
  )

  tags = {
    Name = "${var.project_name}-s3-endpoint"
  }
}

# resource "aws_vpc_endpoint" "vpce" {
#   for_each = local.vpc_endpoints
#   vpc_id   = aws_vpc.main.id

#   service_name      = each.value
#   vpc_endpoint_type = "Interface"

#   security_group_ids = [
#     aws_security_group.vpce.id
#   ]

#   private_dns_enabled = true

#   tags = {
#     Name = "${each.key}-${var.environment}-vpce"
#   }
# }
