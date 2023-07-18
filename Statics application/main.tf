# Variables
variable "aws_region" {
  description = "AWS region where the resources will be created"
  default     = "us-west-2"
}

variable "app_name" {
  description = "Name of the application"
  default     = "my-app"
}

variable "html_file_path" {
  description = "Path to the custom HTML file"
  default     = "/path/to/custom.html"
}

# Provider
provider "aws" {
  region = var.aws_region
}

# Crear namespace
resource "kubernetes_namespace" "app_namespace" {
  metadata {
    name = var.app_name
  }
}

# Crear deployment
resource "kubernetes_deployment" "app_deployment" {
  metadata {
    name      = "${var.app_name}-deployment"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          name  = var.app_name
          image = "nginx"
        }
      }
    }
  }
}

# Crear ALB
resource "kubernetes_ingress" "app_ingress" {
  metadata {
    name      = "${var.app_name}-ingress"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name

    annotations = {
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }

  spec {
    rule {
      http {
        path {
          path    = "/statics.html"
          backend {
            service_name = kubernetes_deployment.app_deployment.metadata[0].name
            service_port = 80
          }
        }
      }
    }
  }
}

# Crear configmap
resource "kubernetes_config_map" "custom_html" {
  metadata {
    name      = "${var.app_name}-custom-html"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  data = {
    index.html = file("${var.html_file_path}")
  }
}

# Crear volume
resource "kubernetes_deployment" "app_deployment_custom_html" {
  metadata {
    name      = "${var.app_name}-deployment-custom-html"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          name  = var.app_name
          image = "nginx"

          volume_mount {
            name       = "html-volume"
            mount_path = "/usr/share/nginx/html"
          }
        }

        volume {
          name = "html-volume"

          config_map {
            name = kubernetes_config_map.custom_html.metadata[0].name
          }
        }
      }
    }
  }
}