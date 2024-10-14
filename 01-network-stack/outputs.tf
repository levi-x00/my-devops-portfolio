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
  value = [aws_subnet.private-1a.id, aws_subnet.private-1b.id]
}

output "public_subnet_ids" {
  value = [aws_subnet.public-1a.id, aws_subnet.public-1b.id]
}

output "default_sg_id" {
  value = aws_default_security_group.default-sg.id
}

output "account_id" {
  value = local.account_id
}

output "kms_key_arn" {
  value = aws_kms_key.kms.arn
}

output "kms_key_id" {
  value = aws_kms_alias.kms.id
}
