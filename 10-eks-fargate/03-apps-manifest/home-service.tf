# Kubernetes Deployment Manifest - Service 1
resource "kubernetes_deployment_v1" "base" {
  metadata {
    name = "base"
    labels = {
      app = "base"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "base"
      }
    }

    template {
      metadata {
        labels = {
          app = "base"
        }
      }

      spec {
        container {
          image = "stacksimplify/kube-nginxapp1:1.0.0"
          name  = "base"
          port {
            container_port = 5000
          }
        }
      }
    }
  }
}

# Kubernetes Service Manifest (Type: Node Port Service) - Service 1
resource "kubernetes_service_v1" "base_service" {
  metadata {
    name = "base-svc"
    annotations = {
      "alb.ingress.kubernetes.io/healthcheck-path" = "/health"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.base.spec.0.selector.0.match_labels.app
    }
    port {
      name        = "http"
      port        = 80
      target_port = 5000
    }
    type = "NodePort"
  }
}
