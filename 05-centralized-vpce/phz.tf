resource "aws_route53_zone" "ssm" {
  name = "ssm.${var.region}.amazonaws.com"
  vpc { vpc_id = module.vpc_vpce.vpc_id }
  vpc { vpc_id = module.vpc_spoke1.vpc_id }
  vpc { vpc_id = module.vpc_spoke2.vpc_id }
}

resource "aws_route53_zone" "ssmmessages" {
  name = "ssmmessages.${var.region}.amazonaws.com"
  vpc { vpc_id = module.vpc_vpce.vpc_id }
  vpc { vpc_id = module.vpc_spoke1.vpc_id }
  vpc { vpc_id = module.vpc_spoke2.vpc_id }
}

resource "aws_route53_zone" "ec2messages" {
  name = "ec2messages.${var.region}.amazonaws.com"
  vpc { vpc_id = module.vpc_vpce.vpc_id }
  vpc { vpc_id = module.vpc_spoke1.vpc_id }
  vpc { vpc_id = module.vpc_spoke2.vpc_id }
}

resource "aws_route53_record" "ssm" {
  zone_id = aws_route53_zone.ssm.zone_id
  name    = "ssm.${var.region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.ssm.dns_entry[0]["dns_name"]
    zone_id                = aws_vpc_endpoint.ssm.dns_entry[0]["hosted_zone_id"]
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ssmmessages" {
  zone_id = aws_route53_zone.ssmmessages.zone_id
  name    = "ssmmessages.${var.region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.ssmmessages.dns_entry[0]["dns_name"]
    zone_id                = aws_vpc_endpoint.ssmmessages.dns_entry[0]["hosted_zone_id"]
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ec2messages" {
  zone_id = aws_route53_zone.ec2messages.zone_id
  name    = "ec2messages.${var.region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.ec2messages.dns_entry[0]["dns_name"]
    zone_id                = aws_vpc_endpoint.ec2messages.dns_entry[0]["hosted_zone_id"]
    evaluate_target_health = true
  }
}
