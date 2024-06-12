provider "aws" {
  profile = var.profile
  region  = var.region

  default_tags {
    tags = var.tags
  }
}
