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

output "internal_lb_sg_id" {
  value = aws_security_group.internal_lb_sg.id
}

output "svc_sg_id" {
  value = aws_security_group.service_sg.id
}

output "http_listener_arn" {
  value = aws_lb_listener.ecs_listener.arn
}

output "http_internal_listener_arn" {
  value = aws_lb_listener.ecs_internal_listener.arn
}

output "https_listener_arn" {
  value = aws_lb_listener.ecs_listener_443.arn
}

output "ecs_svc_linked_role_name" {
  value = aws_iam_service_linked_role.ecs.name
}

output "sns_arn" {
  value = aws_sns_topic.topic.arn
}

output "s3_artifact_bucket" {
  value = aws_s3_bucket.s3_artifact.id
}
