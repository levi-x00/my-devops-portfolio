output "lbc_helm_metadata" {
  value = helm_release.load_balancer_controller.metadata
}

output "autoscaler_helm_metadata" {
  value = helm_release.cluster_autoscaler_release.metadata
}
