#####################################################################
# network and ECS cluster tfstate section
#####################################################################
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket  = var.tfstate_bucket
    key     = var.tfstate_network_key
    region  = var.aws_region
    profile = var.aws_profile
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket  = var.tfstate_bucket
    key     = var.tfstate_ecs_key
    region  = var.aws_region
    profile = var.aws_profile
  }
}

#####################################################################
# local section
#####################################################################
locals {
  cluster_info = data.terraform_remote_state.cluster.outputs
  network_info = data.terraform_remote_state.network.outputs

  listener_arn = local.cluster_info.https_listener_arn
  cluster_name = local.cluster_info.cluster_name

  s3_artifact_bucket = local.cluster_info.s3_artifact_bucket
}

#####################################################################
# service-1 section
#####################################################################
module "service1" {
  source = "../../modules/ecs-task/fargate-cm"

  service_name = "service-1"

  cpu    = var.cpu
  memory = var.memory
  port   = 5001

  path_pattern     = "/${var.service_name}"
  docker_file_path = "${path.module}/src"

  cluster_info = local.cluster_info
  network_info = local.network_info

  min_capacity = 1
  max_capacity = 1

  cpu_target_value = 85
  mem_target_value = 85

}

module "cicd_service1" {
  source = "../../modules/ecs-cicd-ghapps"

  service_name = "service-1"

  cluster_name   = local.cluster_name
  s3_bucket_artf = local.s3_artifact_bucket

  network_info = local.network_info
  ecs_info     = local.cluster_info

  repository_id = "levi-x00/service-1"
  branch_name   = "master"
}

#####################################################################
# service-2 section
#####################################################################
module "service2" {
  source = "../../modules/ecs-task/fargate-cm"

  service_name = "service-2"

  cpu    = var.cpu
  memory = var.memory
  port   = 5002

  path_pattern     = "/${var.service_name}"
  docker_file_path = "${path.module}/src"

  cluster_info = local.cluster_info
  network_info = local.network_info

  min_capacity = 1
  max_capacity = 1

  cpu_target_value = 85
  mem_target_value = 85

}

module "cicd_service2" {
  source = "../../modules/ecs-cicd-ghapps"

  service_name = "service-2"

  cluster_name   = local.cluster_name
  s3_bucket_artf = local.s3_artifact_bucket

  network_info = local.network_info
  ecs_info     = local.cluster_info

  repository_id = "levi-x00/service-2"
  branch_name   = "master"
}

#####################################################################
# base service section
#####################################################################
module "base_service" {
  depends_on = [
    module.service1,
    module.service2
  ]

  source = "../../modules/ecs-task/fargate"

  service_name     = "base-service"
  docker_file_path = "${path.module}/src"

  cpu    = var.cpu
  memory = var.memory
  port   = 5000

  path_pattern = "/*"

  listener_arn = local.listener_arn

  lb_sg_id     = local.cluster_info.alb_security_group_id
  cluster_info = local.cluster_info
  network_info = local.network_info

  min_capacity = 1
  max_capacity = 1

  target_value = 70
}

module "cicd_basesvc" {
  depends_on = [
    module.cicd_service1,
    module.cicd_service2
  ]

  source = "../../modules/ecs-cicd-ghapps"

  service_name = "base-service"
  cluster_name = local.cluster_info.cluster_name

  network_info = local.network_info
  ecs_info     = local.cluster_info

  s3_bucket_artf = local.s3_artifact_bucket

  repository_id = "levi-x00/base-service"
  branch_name   = "master"
}
