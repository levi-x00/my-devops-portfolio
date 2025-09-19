resource "aws_lb_target_group" "service_tg" {
  name     = "${var.service_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  target_type = "ip"

  health_check {
    interval = 7
    path     = "/health"
    port     = var.port
    timeout  = 5
  }

  tags = {
    Name = "${var.service_name}-tg"
  }
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_tg.arn
  }

  condition {
    path_pattern {
      values = [var.path_pattern]
    }
  }
}
