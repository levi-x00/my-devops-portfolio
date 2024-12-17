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
  value = var.enable_lb_ssl == true ? aws_lb_listener.ecs_listener1[0].arn : aws_lb_listener.ecs_listener0[0].arn
}

output "https_listener_arn" {
  value = var.enable_lb_ssl == true ? aws_lb_listener.ecs_listener_443[0].arn : ""
}

output "ecs_svc_linked_role_name" {
  value = aws_iam_service_linked_role.ecs.name
}

output "service_discovery_prv_id" {
  value = aws_service_discovery_private_dns_namespace.internal.id
}

output "service_discovery_prv_http" {
  value = aws_service_discovery_private_dns_namespace.internal.hosted_zone
}

output "service_discovery_prv_arn" {
  value = aws_service_discovery_private_dns_namespace.internal.arn
}

output "svc_sg_id" {
  value = aws_security_group.service_sg.id
}

output "sns_arn" {
  value = aws_sns_topic.topic.arn
}

output "s3_artifact_bucket" {
  value = aws_s3_bucket.s3_artifact.id
}
