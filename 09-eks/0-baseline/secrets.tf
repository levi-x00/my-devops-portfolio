resource "aws_secretsmanager_secret" "db" {
  name       = "test-eks-secrets"
  kms_key_id = local.kms_key_arn

  tags = {
    Environment = var.environment
    Application = var.application
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    DB_HOST     = aws_db_instance.postgres.address
    DB_NAME     = aws_db_instance.postgres.db_name
    DB_USER     = aws_db_instance.postgres.username
    DB_PASSWORD = aws_db_instance.postgres.password
    AWS_REGION  = var.aws_region
    S3_BUCKET   = var.tfstate_bucket
  })
}
