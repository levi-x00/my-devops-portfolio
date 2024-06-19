output "vpc_id" {
  value = aws_vpc.main.id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
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
  value = data.aws_caller_identity.current.account_id
}
