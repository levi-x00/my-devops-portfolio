output "monitoring_namespace" {
  description = "Namespace where monitoring stack is installed"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "grafana_service" {
  description = "Grafana service name"
  value       = "kube-prometheus-stack-grafana"
}

output "prometheus_service" {
  description = "Prometheus service name"
  value       = "kube-prometheus-stack-prometheus"
}
