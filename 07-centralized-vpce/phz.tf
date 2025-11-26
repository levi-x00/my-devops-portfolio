resource "aws_route53_zone" "phz" {
  for_each = toset(var.vpc_endpoints)

  name = "${each.value}.${var.aws_region}.amazonaws.com"

  vpc { vpc_id = module.vpc_vpce.vpc_id }
  vpc { vpc_id = module.vpc_spoke1.vpc_id }
  vpc { vpc_id = module.vpc_spoke2.vpc_id }

  lifecycle {
    ignore_changes = [vpc]
  }
}

resource "aws_route53_record" "phz" {
  for_each = toset(var.vpc_endpoints)

  zone_id = aws_route53_zone.phz[each.value].zone_id

  name = "${each.value}.${var.aws_region}.amazonaws.com"
  type = "A"

  alias {
    name    = aws_vpc_endpoint.vpce[each.value].dns_entry[0]["dns_name"]
    zone_id = aws_vpc_endpoint.vpce[each.value].dns_entry[0]["hosted_zone_id"]

    evaluate_target_health = true
  }
}
