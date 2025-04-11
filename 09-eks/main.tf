module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    vpc-cni = {
      before_compute = true
      most_recent    = true
      configuration_values = jsonencode({
        env = {
          ENABLE_POD_ENI                    = "true"
          ENABLE_PREFIX_DELEGATION          = "true"
          POD_SECURITY_GROUP_ENFORCING_MODE = "standard"
        }
        nodeAgent = {
          enablePolicyEventLogs = "true"
        }
        enableNetworkPolicy = "true"
      })
    }
  }

  vpc_id     = local.vpc_id
  subnet_ids = local.prv_subnets

  create_cluster_security_group = true
  create_node_security_group    = false

  eks_managed_node_groups = {
    myapp-ng = {
      instance_types           = [var.instance_type]
      force_update_version     = true
      release_version          = var.ami_release_version
      use_name_prefix          = false
      iam_role_name            = "${var.cluster_name}-ng-role"
      iam_role_use_name_prefix = false

      min_size     = 1
      max_size     = 2
      desired_size = 1

      disk_size   = var.disk_size
      volume_type = var.volume_type

      update_config = {
        max_unavailable_percentage = 50
      }

      labels = {
        service_name = "myapp"
      }
    }
  }

  tags = {
    Name                     = var.cluster_name
    "karpenter.sh/discovery" = var.cluster_name
  }
}
