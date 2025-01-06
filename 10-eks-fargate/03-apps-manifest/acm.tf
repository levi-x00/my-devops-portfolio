# Resource: ACM Certificate
resource "aws_acm_certificate" "acm_cert" {
  domain_name       = "*.${var.external_dns}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
