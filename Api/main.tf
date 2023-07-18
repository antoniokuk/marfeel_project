# Crea el espacio de nombres de la aplicación
resource "kubernetes_namespace" "api_app_namespace" {
  metadata {
    name = "api-app"
  }
}

# Crea el Deployment de la aplicación
resource "kubernetes_deployment" "api_app_deployment" {
  metadata {
    name      = "api-app-deployment"
    namespace = kubernetes_namespace.api_app_namespace.metadata.0.name
  }

  spec {
    selector {
      match_labels = {
        app = "api-app"
      }
    }

    replicas = 1

    template {
      metadata {
        labels = {
          app = "api-app"
        }
      }

      spec {
        container {
          name  = "api-app-container"
          image = "gcr.io/google_containers/echoserver:1.4"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

# Crea el Service para exponer la aplicación
resource "kubernetes_service" "api_app_service" {
  metadata {
    name      = "api-app-service"
    namespace = kubernetes_namespace.api_app_namespace.metadata.0.name
  }

  spec {
    selector = {
      app = "api-app"
    }

    port {
      protocol = "TCP"
      port     = 80
      target_port = 8080
    }
  }
}

# Crea el Ingress para dirigir las solicitudes a la aplicación
resource "kubernetes_ingress" "api_app_ingress" {
  metadata {
    name      = "api-app-ingress"
    namespace = kubernetes_namespace.api_app_namespace.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }

  spec {
    rule {
      http {
        path {
          path    = "/api"
          backend {
            service_name = kubernetes_service.api_app_service.metadata.0.name
            service_port = 80
          }
        }
      }
    }
  }
}