output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "kms_key_arn" {
  value = aws_kms_key.kms.arn
}

output "kms_key_id" {
  value = aws_kms_alias.kms.id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}
