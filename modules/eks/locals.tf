locals {
  tag_resource_types = ["instance", "network-interface", "volume"]

  private_subnet_tags = merge([
    for subnet_id in var.private_subnet_ids : {
      "${subnet_id}/kubernetes.io/role/internal-elb"           = { resource_id = subnet_id, key = "kubernetes.io/role/internal-elb", value = "1" }
      "${subnet_id}/kubernetes.io/cluster/${var.cluster_name}" = { resource_id = subnet_id, key = "kubernetes.io/cluster/${var.cluster_name}", value = "shared" }
      "${subnet_id}/karpenter.sh/discovery"                    = { resource_id = subnet_id, key = "karpenter.sh/discovery", value = var.cluster_name }
    }
  ]...)

  public_subnet_tags = merge([
    for subnet_id in var.public_subnet_ids : {
      "${subnet_id}/kubernetes.io/role/elb"                    = { resource_id = subnet_id, key = "kubernetes.io/role/elb", value = "1" }
      "${subnet_id}/kubernetes.io/cluster/${var.cluster_name}" = { resource_id = subnet_id, key = "kubernetes.io/cluster/${var.cluster_name}", value = "shared" }
    }
  ]...)
}
