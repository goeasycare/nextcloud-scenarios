data "cloudflare_zone" "app_zone" {
  zone_id = var.cloudflare_config.app_zone_id
}

data "kubernetes_service" "nginx" {
  metadata {
    name      = "web-ingress-nginx-controller"
    namespace = "ingress"
  }
}
