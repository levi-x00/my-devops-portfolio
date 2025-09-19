locals {

  cluster_info = var.cluster_info
  network_info = var.network_info

  kms_key_arn = local.network_info.kms_key_arn

  cluster_name = local.cluster_info.cluster_name
  aws_region   = local.cluster_info.aws_region

  lb_sg_id  = local.cluster_info.lb_sg_id
  svc_sg_id = local.cluster_info.service_security_group_id

  # http_listener_arn  = local.cluster_info.http_listener_arn
  # https_listener_arn = local.cluster_info.https_listener_arn

  vpc_id  = local.network_info.vpc_id
  subnets = local.network_info.private_subnet_ids

  ecs_svc_linked_role_name = local.cluster_info.ecs_svc_linked_role_name
}
