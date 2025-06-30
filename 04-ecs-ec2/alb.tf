#---------------------------------------------------------------------------------------
# public LB section
#---------------------------------------------------------------------------------------
resource "aws_lb" "public_lb" {
  depends_on = [
    aws_s3_bucket_policy.s3_lb_logs
  ]
  name               = "${var.cluster_name}-public-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.lb_sg.id]
  subnets         = local.lb_subnets

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.s3_lb_logs.id
    prefix  = "${var.cluster_name}-public-alb"
    enabled = true
  }

  tags = {
    Environment = "${var.cluster_name}-public-alb"
  }
}

resource "aws_lb_listener" "pub_ecs_listener" {
  load_balancer_arn = aws_lb.public_lb.arn

  port     = "80"
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name = "ecs-http-listener"
  }
}

resource "aws_lb_listener" "pub_ecs_listener_443" {
  depends_on = [
    time_sleep.wait_60_seconds
  ]
  load_balancer_arn = aws_lb.public_lb.arn

  port     = "443"
  protocol = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.acm.arn

  default_action {
    order = 1
    type  = "fixed-response"
    fixed_response {
      content_type = "application/json"
      message_body = "{\"message\": \"Not Found!\"}"
      status_code  = "404"
    }
  }

  tags = {
    Name = "ecs-pub-https-listener"
  }
}

resource "aws_route53_record" "pub_alb_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.public_lb.dns_name
    zone_id                = aws_lb.public_lb.zone_id
    evaluate_target_health = true
  }
}
