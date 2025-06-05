resource "aws_cloudwatch_log_group" "performance" {
  name = "/aws/containerinsights/${var.cluster_name}/performance"

  retention_in_days = 180
}

resource "aws_cloudwatch_log_group" "application" {
  name = "/aws/containerinsights/${var.cluster_name}/application"

  retention_in_days = 180
}

resource "aws_cloudwatch_log_group" "dataplane" {
  name = "/aws/containerinsights/${var.cluster_name}/dataplane"

  retention_in_days = 180
}

resource "aws_cloudwatch_log_group" "host" {
  name = "/aws/containerinsights/${var.cluster_name}/host"

  retention_in_days = 180
}
