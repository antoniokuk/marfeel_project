# Crear el espacio de nombres para la aplicación
resource "kubernetes_namespace" "app_namespace" {
  metadata {
    name = "my-app-namespace"
  }
}

# Crear el ConfigMap para almacenar el archivo HTML personalizado
resource "kubernetes_config_map" "custom_html" {
  metadata {
    name      = "custom-html"
    namespace = kubernetes_namespace.app_namespace.metadata.0.name
  }

  data = {
    "statics.html" = <<-EOT
<html>
<head>
  <title>Custom HTML Page</title>
</head>
<body>
  <h1>Bienvenido a mi página HTML personalizada!</h1>
</body>
</html>
EOT
  }
}

# Crear el Deployment para la aplicación nginx
resource "kubernetes_deployment" "app_deployment" {
  metadata {
    name      = "my-app-deployment"
    namespace = kubernetes_namespace.app_namespace.metadata.0.name
  }

  spec {
    selector {
      match_labels = {
        app = "my-app"
      }
    }

    replicas = 1

    template {
      metadata {
        labels = {
          app = "my-app"
        }
      }

      spec {
        container {
          name  = "my-app-container"
          image = "nginx"

          ports {
            container_port = 80
          }

          volume_mount {
            name       = "custom-html-volume"
            mount_path = "/usr/share/nginx/html"
            read_only  = true
          }
        }

        volume {
          name = "custom-html-volume"

          config_map {
            name = kubernetes_config_map.custom_html.metadata.0.name
          }
        }
      }
    }
  }
}

# Crear el Service para exponer la aplicación
resource "kubernetes_service" "app_service" {
  metadata {
    name      = "my-app-service"
    namespace = kubernetes_namespace.app_namespace.metadata.0.name
  }

  spec {
    selector = {
      app = "my-app"
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
  }
}

# Crear el Ingress para dirigir las solicitudes a /statics.html hacia la aplicación
resource "kubernetes_ingress" "app_ingress" {
  metadata {
    name      = "my-app-ingress"
    namespace = kubernetes_namespace.app_namespace.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
    }
  }

  spec {
    rule {
      http {
        path {
          path    = "/statics.html"
          backend {
            service_name = kubernetes_service.app_service.metadata.0.name
            service_port = 80
          }
        }
      }
    }
  }
}