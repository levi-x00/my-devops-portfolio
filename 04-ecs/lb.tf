resource "aws_security_group" "lb_sg" {
  name   = "${var.cluster_name}-alb-sg"
  vpc_id = local.vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # ingress {
  #   from_port   = 0
  #   to_port     = 65535
  #   protocol    = "tcp"
  #   cidr_blocks = [local.vpc_cidr_block]
  # }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_block]
  }

  lifecycle {
    ignore_changes = [
      ingress,
      egress
    ]
  }

  tags = {
    Name = "${var.cluster_name}-alb-sg"
  }
}

resource "aws_security_group" "internal_lb_sg" {
  name   = "${var.cluster_name}-internal-alb-sg"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = -1
  #   cidr_blocks = [local.vpc_cidr_block]
  # }

  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = -1
  #   cidr_blocks = [local.vpc_cidr_block]
  # }

  tags = {
    Name = "${var.cluster_name}-internal-alb-sg"
  }
}

resource "aws_security_group" "service_sg" {
  depends_on = [
    aws_security_group.lb_sg
  ]

  name   = "${var.cluster_name}-svc-sg"
  vpc_id = local.vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_groups  = [aws_security_group.lb_sg.id]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_groups  = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    ignore_changes = [
      ingress,
      egress
    ]
  }

  tags = {
    Name = "${var.cluster_name}-svc-sg"
  }
}

resource "aws_lb" "cluster" {
  name               = "${var.cluster_name}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.lb_sg.id]
  subnets         = local.lb_subnets

  enable_deletion_protection = false
  access_logs {
    bucket  = aws_s3_bucket_policy.s3_lb_logs.id
    prefix  = "${var.cluster_name}-public-alb"
    enabled = true
  }

  tags = {
    Environment = "${var.cluster_name}-alb"
  }
}

resource "aws_lb" "internal_lb" {
  name               = "${var.cluster_name}-internal-alb"
  internal           = true
  load_balancer_type = "application"

  security_groups = [aws_security_group.internal_lb_sg.id]
  subnets         = local.prv_subnets

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket_policy.s3_lb_logs.id
    prefix  = "${var.cluster_name}-internal-alb"
    enabled = true
  }

  tags = {
    Environment = "${var.cluster_name}-internal-alb"
  }
}

resource "aws_lb_listener" "ecs_internal_listener" {
  load_balancer_arn = aws_lb.internal_lb.arn

  port     = "80"
  protocol = "HTTP"

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
    Name = "ecs-http-internal-listener"
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
  certificate_arn = aws_acm_certificate.acm.arn

  default_action {
    order = 1
    type  = "fixed-response"
    fixed_response {
      content_type = "application/json"
      message_body = "{\"message\": \"Not Found!!\"}"
      status_code  = "404"
    }
  }

  tags = {
    Name = "ecs-https-listener"
  }
}

resource "aws_route53_record" "alb_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.service_domain
  type    = "A"

  alias {
    name                   = aws_lb.cluster.dns_name
    zone_id                = aws_lb.cluster.zone_id
    evaluate_target_health = true
  }
}
