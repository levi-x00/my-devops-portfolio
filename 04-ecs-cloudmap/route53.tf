data "aws_route53_zone" "selected" {
  name         = var.public_domain
  private_zone = false
}

resource "aws_acm_certificate" "acm" {
  count             = var.enable_lb_ssl == true ? 1 : 0
  domain_name       = var.public_domain
  validation_method = "DNS"

  tags = {
    Name = var.public_domain
  }
}

#------------------------------------------------------------------------------------------------------
# Create ACM record in route53 for validation
#------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "r53_record" {
  for_each = {
    for dvo in aws_acm_certificate.acm[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true

  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.selected.zone_id
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [
    aws_acm_certificate.acm[0],
    aws_route53_record.r53_record
  ]
  create_duration = "90s"
}
