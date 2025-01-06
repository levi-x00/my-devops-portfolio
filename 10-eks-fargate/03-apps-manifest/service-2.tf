# Kubernetes Deployment Manifest - Service 2
resource "kubernetes_deployment_v1" "service2" {
  metadata {
    name = "service-2"
    labels = {
      app = "service-2"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "service-2"
      }
    }

    template {
      metadata {
        labels = {
          app = "service-2"
        }
      }

      spec {
        container {
          image = "stacksimplify/kube-nginxapp1:1.0.0"
          name  = "service-2"
          port {
            container_port = 5002
          }
        }
      }
    }
  }
}

# Kubernetes Service Manifest (Type: Node Port Service) - Service 2
resource "kubernetes_service_v1" "service2_service" {
  metadata {
    name = "service-2-svc"
    annotations = {
      "alb.ingress.kubernetes.io/healthcheck-path" = "/health"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.service2.spec.0.selector.0.match_labels.app
    }
    port {
      name        = "http"
      port        = 80
      target_port = 5002
    }
    type = "NodePort"
  }
}
