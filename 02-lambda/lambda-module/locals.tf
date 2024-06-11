locals {
  function_name = var.lambda_name
  inline_policy = var.lambda_inline_policy

  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids

  hash_source_dir = data.external.folder_hash.result.hash
}
