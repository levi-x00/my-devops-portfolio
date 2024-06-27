locals {
  tags = {
    Environment = var.environment
    Purpose     = "centralized egress"
    Application = var.application
  }
}
