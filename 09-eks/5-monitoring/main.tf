resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"

  parameters = {
    type      = "gp3"
    encrypted = "true"
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = var.kube_prometheus_stack_version

  values = [
    templatefile("${path.module}/helm/values.yaml", {
      prometheus_retention      = var.prometheus_retention
      prometheus_storage_size   = var.prometheus_storage_size
      alertmanager_storage_size = var.alertmanager_storage_size
      grafana_storage_size      = var.grafana_storage_size
      grafana_admin_password    = var.grafana_admin_password
    })
  ]

  depends_on = [kubernetes_namespace.monitoring, kubernetes_storage_class.gp3]

  timeout = 600
  atomic  = false
  wait    = false
}
