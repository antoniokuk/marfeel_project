# Define variables
variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "branch_name" {
  description = "Name of the branch to deploy"
  type        = string
}

# Define clusters
locals {
  clusters = {
    dev = {
      branch = "dev",
      html   = "This is the dev branch"
    },
    stage = {
      branch = "stage",
      html   = "This is the stage branch"
    },
    production = {
      branch = "master",
      html   = "This is the production branch"
    }
  }
}

# Resource: ConfigMap
resource "kubernetes_config_map" "custom_html" {
  metadata {
    name      = "custom-html"
    namespace = var.cluster_name
  }

  data = {
    "static.html" = local.clusters[var.cluster_name].html
  }
}

# Resource: Deployment
resource "kubernetes_deployment" "application" {
  metadata {
    name      = "application"
    namespace = var.cluster_name
  }

  spec {
    # ... deployment configuration ...

    template {
      # ... pod template configuration ...

      spec {
        # ... container configuration ...

        env {
          name  = "BRANCH_NAME"
          value = local.clusters[var.cluster_name].branch
        }
      }
    }
  }
}