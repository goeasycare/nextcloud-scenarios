# resource "cloudflare_record" "nextcloud" {
#   zone_id = var.cloudflare_config.app_zone_id
#   type    = "A"
#   name    = "nextcloud.goeasycare.app"
#   value   = data.kubernetes_service.nginx.status[0].load_balancer[0].ingress[0].ip
#   proxied = true
# }
