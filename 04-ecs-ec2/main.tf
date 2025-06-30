resource "aws_cloudwatch_log_group" "cluster" {
  name       = "${var.cluster_name}-logs"
  kms_key_id = local.kms_key_arn

  retention_in_days = var.retention_days
  tags = {
    Name = "${var.cluster_name}-logs"
  }
}

# please delete ECS service role first in order for this to run
resource "aws_iam_service_linked_role" "ecs" {
  aws_service_name = "ecs.amazonaws.com"
}

resource "aws_ecs_cluster" "cluster" {
  depends_on = [
    aws_iam_service_linked_role.ecs,
    aws_cloudwatch_log_group.cluster
  ]

  name = var.cluster_name

  configuration {
    # execute_command_configuration {
    #   kms_key_id = local.kms_key_arn
    #   logging    = "OVERRIDE"

    #   log_configuration {
    #     cloud_watch_encryption_enabled = true
    #     cloud_watch_log_group_name     = aws_cloudwatch_log_group.cluster.name
    #   }
    # }

    managed_storage_configuration {
      kms_key_id = local.kms_key_id
    }
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = var.cluster_name
  }
}
