output "lambda_arn" {
  value = aws_lambda_function.this.arn
}

output "code_sha256" {
  value = aws_lambda_function.this.code_sha256
}
