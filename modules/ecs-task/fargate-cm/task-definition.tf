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
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_block]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.service_name}-svc-sg"
  }
}

resource "aws_ecs_task_definition" "task_def" {
  depends_on = [
    null_resource.push_image
  ]

  container_definitions = jsonencode([
    {
      "cpu" : 0,
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
      "cpu" : 0,
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

  requires_compatibilities = ["FARGATE"]

  cpu          = var.cpu
  family       = "${var.service_name}-task-def"
  memory       = var.memory
  network_mode = "awsvpc"

  task_role_arn      = aws_iam_role.task_role.arn
  execution_role_arn = aws_iam_role.task_role.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  tags = {
    Name = "${var.service_name}-task-def"
  }
}
