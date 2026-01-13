variable "cloudflare_config" {
  sensitive   = true
  description = "Cloudflare zone api token"
  type = object({
    api_token      = string
    app_zone_id    = string
    origin_api_key = string
  })
}
