data "aws_ecr_image" "service_image" {
  depends_on = [
    null_resource.push_image
  ]

  repository_name = "${var.service_name}-ecr"
  image_tag       = "latest"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  image_uri = "${aws_ecr_repository.this.repository_url}@${data.aws_ecr_image.service_image.id}"

  cluster_info = var.cluster_info
  network_info = var.network_info

  cluster_name   = local.cluster_info.cluster_name
  alb_arn        = local.cluster_info.alb_arn
  svc_sg_id      = local.cluster_info.svc_sg_id
  vpc_cidr_block = local.network_info.vpc_cidr_block
  vpc_id         = local.network_info.vpc_id
  subnets        = local.network_info.private_subnet_ids

  ecs_svc_linked_role_name = local.cluster_info.ecs_svc_linked_role_name
}
