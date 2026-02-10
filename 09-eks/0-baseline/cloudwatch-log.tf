resource "aws_cloudwatch_log_group" "container_insights" {
  for_each = toset(["performance", "application", "dataplane", "host"])

  name              = "/aws/containerinsights/${var.cluster_name}/${each.key}"
  retention_in_days = var.retention_in_days
}
