output "backend_pipeline_arn" {
  description = "ARN of the backend CodePipeline"
  value       = module.backend_pipeline.arn
}

output "frontend_pipeline_arn" {
  description = "ARN of the frontend CodePipeline"
  value       = module.frontend_pipeline.arn
}

output "backend_codecommit_clone_url" {
  description = "HTTPS clone URL for the backend CodeCommit repository"
  value       = aws_codecommit_repository.backend.clone_url_http
}

output "frontend_codecommit_clone_url" {
  description = "HTTPS clone URL for the frontend CodeCommit repository"
  value       = aws_codecommit_repository.frontend.clone_url_http
}

output "artifacts_bucket" {
  description = "S3 bucket used for pipeline artifacts"
  value       = module.artifacts_bucket.bucket_name
}
