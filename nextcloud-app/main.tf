locals {
  container_port = var.container_port
}

# Create single secret automatically when values are provided
resource "kubernetes_secret" "nextcloud" {
  count = length(var.secret_environment_variables) > 0 || var.nextcloud_password != null ? 1 : 0

  metadata {
    name      = "${var.name}-secrets"
    namespace = var.namespace
    labels = {
      app            = var.app_label
      "managed-by"   = "terraform"
      "auto-created" = "true"
    }
  }

  data = merge(
    # Include admin credentials if password is provided
    var.nextcloud_password != null ? {
      "NEXTCLOUD_ADMIN_USER"     = var.nextcloud_username
      "NEXTCLOUD_ADMIN_PASSWORD" = var.nextcloud_password
    } : {},
    # Include user-provided secret environment variables
    {
      for secret_var in var.secret_environment_variables :
      secret_var.name => secret_var.value
    }
  )

  type = "Opaque"
}

resource "kubernetes_deployment" "nextcloud" {
  depends_on = [kubernetes_secret.nextcloud]

  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = { app = var.app_label }
  }
  spec {
    replicas = var.replicas
    selector { match_labels = { app = var.app_label } }
    template {
      metadata { labels = { app = var.app_label } }
      spec {
        container {
          name  = var.name
          image = var.image

          # Use configurable container port
          port { container_port = local.container_port }

          # Dynamic environment variables from plain values
          dynamic "env" {
            for_each = var.environment_variables
            content {
              name  = env.value.name
              value = env.value.value
            }
          }

          # Dynamic environment variables from secrets (including admin credentials)
          dynamic "env" {
            for_each = concat(
              # Add admin credential env vars if password is provided
              var.nextcloud_password != null ? [
                { name = "NEXTCLOUD_ADMIN_USER" },
                { name = "NEXTCLOUD_ADMIN_PASSWORD" }
              ] : [],
              # Add user-provided secret env vars
              [for secret_var in var.secret_environment_variables : { name = secret_var.name }]
            )
            content {
              name = env.value.name
              value_from {
                secret_key_ref {
                  name = kubernetes_secret.nextcloud[0].metadata[0].name
                  key  = env.value.name
                }
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nextcloud" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = { app = var.app_label }
  }
  spec {
    selector = { app = var.app_label }
    port {
      port        = var.service_port
      target_port = local.container_port # Reference the local instead of hardcoded 80
    }
    type = var.service_type
  }
}

output "service_name" { value = kubernetes_service.nextcloud.metadata[0].name }

output "created_secrets" {
  value = length(kubernetes_secret.nextcloud) > 0 ? {
    name      = kubernetes_secret.nextcloud[0].metadata[0].name
    namespace = kubernetes_secret.nextcloud[0].metadata[0].namespace
    keys      = keys(kubernetes_secret.nextcloud[0].data)
  } : null
  description = "Information about automatically created secret"
}
