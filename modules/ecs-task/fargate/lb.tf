resource "aws_vpc_security_group_ingress_rule" "ingress_lb" {
  security_group_id = local.lb_sg_id
  from_port         = var.port
  ip_protocol       = "tcp"
  to_port           = var.port

  referenced_security_group_id = aws_security_group.service_sg.id
}

resource "aws_vpc_security_group_egress_rule" "egress_lb" {
  security_group_id = local.lb_sg_id
  from_port         = var.port
  ip_protocol       = "tcp"
  to_port           = var.port

  referenced_security_group_id = aws_security_group.service_sg.id
}

resource "aws_lb_target_group" "service_tg" {
  count    = var.create_listener == true ? 1 : 0
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
  count        = var.create_listener == true ? 1 : 0
  listener_arn = local.https_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_tg[0].arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}
