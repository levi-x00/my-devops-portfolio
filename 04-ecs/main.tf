resource "aws_cloudwatch_log_group" "cluster" {
  name       = "${var.cluster_name}-logs"
  kms_key_id = local.kms_key_arn

  retention_in_days = var.retention_days
  tags = {
    Name = "${var.cluster_name}-logs"
  }
}

resource "aws_cloudwatch_log_group" "sess_manager" {
  name       = "${var.cluster_name}-sessm-logs"
  kms_key_id = local.kms_key_arn

  retention_in_days = var.retention_days
  tags = {
    Name = "${var.cluster_name}-sessm-logs"
  }
}

resource "aws_ecs_cluster" "cluster" {
  depends_on = [
    aws_s3_bucket.s3_sess_manager,
    aws_cloudwatch_log_group.cluster
  ]

  name = var.cluster_name

  configuration {
    execute_command_configuration {
      kms_key_id = local.kms_key_arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.cluster.name
        s3_bucket_name             = aws_s3_bucket.s3_sess_manager.id
        s3_key_prefix              = "exec-output"
      }
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
