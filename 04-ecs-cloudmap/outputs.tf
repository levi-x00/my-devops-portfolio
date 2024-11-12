output "cluster_name" {
  value = var.cluster_name
}

output "cluster_arn" {
  value = aws_ecs_cluster.cluster.arn
}

output "alb_arn" {
  value = aws_lb.cluster.arn
}

output "lb_sg_id" {
  value = aws_security_group.lb_sg.id
}

output "http_listener_arn" {
  value = aws_lb_listener.ecs_listener.arn
}

output "https_listener_arn" {
  value = aws_lb_listener.ecs_listener_443.arn
}

output "ecs_svc_linked_role_name" {
  value = aws_iam_service_linked_role.ecs.name
}

output "service_discovery_id" {
  value = aws_service_discovery_private_dns_namespace.internal.id
}

output "service_discovery_http" {
  value = aws_service_discovery_private_dns_namespace.internal.hosted_zone
}

output "service_discovery_arn" {
  value = aws_service_discovery_private_dns_namespace.internal.arn
}

output "s3_artifact_bucket" {
  value = aws_s3_bucket.s3_artifact.id
}
