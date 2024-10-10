resource "aws_ecs_service" "ecs_service" {
  name          = var.service_name
  cluster       = local.cluster_name
  desired_count = 2

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 0
  enable_ecs_managed_tags            = true

  launch_type     = "EC2"
  task_definition = aws_ecs_task_definition.task_def.arn

  service_registries {
    registry_arn = local.registry_arn
  }

  # alarms {
  #   alarm_names = []
  #   enable      = false
  #   rollback    = false
  # }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    container_name   = var.service_name
    container_port   = var.port
    target_group_arn = aws_lb_target_group.service_tg.arn
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.service_sg.id]
    subnets          = local.subnets
  }

  # spread tasks evenly accross all AZs for HA
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  # make use of all available space on the Container Instances
  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  # enable ci/cd and scaling to override this later
  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }

  tags = {
    Name = var.service_name
  }
}
