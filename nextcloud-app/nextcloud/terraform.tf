terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.79.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.13.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_config.api_token
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
