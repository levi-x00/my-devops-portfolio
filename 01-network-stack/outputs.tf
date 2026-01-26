output "vpc_id" {
  value = aws_vpc.main.id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "cluster_name" {
  value = var.cluster_name
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "db_subnet_ids" {
  value = aws_subnet.db[*].id
}

output "default_sg_id" {
  value = aws_default_security_group.default-sg.id
}

output "account_id" {
  value = local.account_id
}

output "aws_region" {
  value = var.aws_region
}

output "kms_key_arn" {
  value = aws_kms_key.kms.arn
}

output "kms_key_id" {
  value = aws_kms_alias.kms.id
}

output "vpc_cidr_block" {
  value = var.vpc_cidr_block
}
