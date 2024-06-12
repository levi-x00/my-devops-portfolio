locals {

  account_id = data.aws_caller_identity.current.account_id

  function_name = var.lambda_name
  inline_policy = var.lambda_inline_policy

  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids

  source_dir_hash = data.external.folder_hash.result.hash

  ecr_repository_name = "${local.function_name}-ecr"
  image_tag           = "latest"
}
