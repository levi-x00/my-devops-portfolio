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

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_service_discovery_private_dns_namespace" "internal" {
  name        = "devops-portfolio.internal"
  description = "service discovery internal access"
  vpc         = local.vpc_id
}
