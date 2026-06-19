module "eks" {
  source = "../../modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id             = local.vpc_id
  vpc_cidr_block     = local.vpc_cidr_block
  private_subnet_ids = local.private_subnet_ids
  public_subnet_ids  = local.public_subnet_ids
  kms_key_arn        = local.kms_key_arn

  node_groups       = var.node_groups
  cluster_addons    = var.cluster_addons
  volume_size       = var.volume_size
  volume_type       = var.volume_type
  eks_cluster_cidr  = var.eks_cluster_cidr
  cluster_dns_ip    = var.cluster_dns_ip
  retention_in_days = var.retention_in_days

  map_users = var.map_users

  map_roles = [
    {
      rolearn  = aws_iam_role.codebuild.arn
      username = "codepipeline"
      groups   = ["system:masters"]
    }
  ]

  tags = {
    Environment = var.environment
    Application = var.application
  }
}

resource "random_password" "db" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

########################################################################
# RDS PostgreSQL
########################################################################
resource "aws_security_group" "rds" {
  name        = "${var.cluster_name}-rds"
  description = "RDS PostgreSQL security group"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.cluster_name}-rds" }
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.cluster_name}-rds"
  subnet_ids = local.private_subnet_ids

  tags = { Name = "${var.cluster_name}-rds" }
}

resource "aws_db_instance" "postgres" {
  identifier        = "${var.cluster_name}-postgres"
  engine            = "postgres"
  engine_version    = "17"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true
  kms_key_id        = local.kms_key_arn

  db_name  = "appdb"
  username = "dbadmin"
  password = var.db_password != "" ? var.db_password : random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az            = false
  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = false

  tags = { Name = "${var.cluster_name}-postgres" }
}
