# Kubernetes Deployment Manifest - Service 1
resource "kubernetes_deployment_v1" "service1" {
  metadata {
    name = "service-1"
    labels = {
      app = "service-1"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "service-1"
      }
    }

    template {
      metadata {
        labels = {
          app = "service-1"
        }
      }

      spec {
        container {
          image = "stacksimplify/kube-nginxapp1:1.0.0"
          name  = "service-1"
          port {
            container_port = 5001
          }
        }
      }
    }
  }
}

# Kubernetes Service Manifest (Type: Node Port Service) - Service 1
resource "kubernetes_service_v1" "service1_service" {
  metadata {
    name = "service-1-svc"
    annotations = {
      "alb.ingress.kubernetes.io/healthcheck-path" = "/health"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.service1.spec.0.selector.0.match_labels.app
    }
    port {
      name        = "http"
      port        = 80
      target_port = 5001
    }
    type = "NodePort"
  }
}
