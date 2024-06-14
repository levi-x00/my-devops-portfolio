output "image_id" {
  value = data.aws_ecr_image.service_image.id
}

output "repository_name" {
  value = "${var.service_name}-repo"
}

output "repository_uri" {
  value = aws_ecr_repository.this.repository_url
}

# output "image_uri" {
#   value = local.image_uri
# }

output "service_tg_arn" {
  value = aws_lb_target_group.service_tg.arn
}

output "listener_arn" {
  value = local.https_listener_arn
}

output "service_name" {
  value = var.service_name
}
