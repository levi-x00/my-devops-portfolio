# output "image_id" {
#   value = data.aws_ecr_image.service_image.id
# }

output "repository_name" {
  value = "${var.service_name}-repo"
}

output "repository_uri" {
  value = aws_ecr_repository.this.repository_url
}

output "service_name" {
  value = var.service_name
}
