data "aws_route53_zone" "selected" {
  name         = local.domain_name
  private_zone = false
}

resource "aws_acm_certificate" "acm" {
  domain_name       = local.domain_name
  validation_method = "DNS"

  tags = {}
}

#------------------------------------------------------------------------------------------------------
# Create ACM record in route53 for validation
#------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "r53_record" {
  for_each = {
    for dvo in aws_acm_certificate.acm.domain_validation_options : dvo.domain_name => {
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
    aws_acm_certificate.acm,
    aws_route53_record.r53_record
  ]
  create_duration = "60s"
}
