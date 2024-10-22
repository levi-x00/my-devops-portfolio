resource "aws_cloudwatch_log_group" "svc_logs" {
  name = "/aws/ecs/${var.service_name}-logs"

  retention_in_days = var.retention_days
  tags = {
    Name = "${var.service_name}-logs"
  }
}

resource "aws_cloudwatch_log_group" "otel_logs" {
  name = "/aws/ecs/${var.service_name}-otel-logs"

  retention_in_days = var.retention_days
  tags = {
    Name = "/aws/ecs/${var.service_name}-otel-logs"
  }
}

resource "aws_security_group" "service_sg" {
  name   = "${var.service_name}-svc-sg"
  vpc_id = local.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [local.lb_sg_id]
  }

  ingress {
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    security_groups = [local.lb_sg_id]
  }

  egress {
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    security_groups = [local.lb_sg_id]
  }

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [local.lb_sg_id]
  }

  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.service_name}-svc-sg"
  }
}

resource "aws_ecs_task_definition" "task_def" {
  depends_on = [
    null_resource.push_image
  ]

  family = "${var.service_name}-task-def"

  task_role_arn = aws_iam_role.task_role.arn
  network_mode  = "awsvpc"

  execution_role_arn = aws_iam_role.task_role.arn

  cpu    = var.cpu
  memory = var.memory

  container_definitions = jsonencode([
    {
      "environment" : [],
      "environmentFiles" : [],
      "essential" : true,
      "healthCheck" : {
        "command" : [
          "CMD-SHELL",
          "curl -f http://localhost:${var.port}/health || exit 1"
        ],
        "interval" : 30,
        "retries" : 3,
        "timeout" : 10,
        "startPeriod" : 60,
      },
      "image" : "${local.image_uri}",
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "/aws/ecs/${var.service_name}-logs",
          "awslogs-region" : "${local.region}",
          "awslogs-stream-prefix" : "${var.service_name}"
        },
        "secretOptions" : []
      },
      "mountPoints" : [],
      "name" : "${var.service_name}",
      "portMappings" : [
        {
          "appProtocol" : "http",
          "containerPort" : "${var.port}",
          "hostPort" : "${var.port}",
          "name" : "${var.service_name}-${var.port}-tcp",
          "protocol" : "tcp"
        }
      ],
      "systemControls" : [],
      "ulimits" : [],
      "volumesFrom" : []
    },
    {
      "command" : [
        "--config=/etc/ecs/ecs-cloudwatch.yaml"
      ],
      "environment" : [],
      "essential" : true,
      "image" : "public.ecr.aws/aws-observability/aws-otel-collector:v0.39.0",
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "/aws/ecs/${var.service_name}-otel-logs",
          "awslogs-region" : "${local.region}",
          "awslogs-stream-prefix" : "${var.service_name}"
        }
      },
      "mountPoints" : [],
      "name" : "aws-otel-collector",
      "portMappings" : [],
      "systemControls" : [],
      "volumesFrom" : []
    }
  ])

  tags = {
    Name = "${var.service_name}-task-def"
  }
}
