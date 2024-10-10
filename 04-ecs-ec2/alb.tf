resource "aws_lb" "cluster" {
  name               = "${var.cluster_name}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.lb_sg.id]
  subnets         = local.lb_subnets

  enable_deletion_protection = false

  #   access_logs {
  #     bucket  = aws_s3_bucket.lb_logs.id
  #     prefix  = "test-lb"
  #     enabled = true
  #   }

  tags = {
    Environment = "${var.cluster_name}-alb"
  }
}

resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.cluster.arn

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

resource "aws_lb_listener" "ecs_listener_443" {
  load_balancer_arn = aws_lb.cluster.arn

  port     = "443"
  protocol = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = local.certificate_arn

  default_action {
    order = 1
    type  = "fixed-response"
    fixed_response {
      content_type = "application/json"
      message_body = "{\"message\": \"hello devops!!\"}"
      status_code  = "200"
    }
  }

  tags = {
    Name = "ecs-https-listener"
  }
}

resource "aws_route53_record" "alb_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.public_domain
  type    = "A"

  alias {
    name                   = aws_lb.cluster.dns_name
    zone_id                = aws_lb.cluster.zone_id
    evaluate_target_health = true
  }
}
