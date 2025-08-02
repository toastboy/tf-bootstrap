terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.6.0"
    }

    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.1.0"
    }
  }
  cloud {
    organization = "toastboy"

    workspaces {
      name = "tf-bootstrap"
    }
  }
}

provider "cloudflare" {
  api_token = var.bootstrap_cloudflare_api_token
}

data "cloudflare_zones" "zones" {
  account = {
    id = var.bootstrap_cloudflare_account_id
  }
  name = "toastboy.co.uk"
}

data "cloudflare_zone" "toastboy_co_uk" {
  zone_id = data.cloudflare_zones.zones.result[0].id
}

resource "cloudflare_zero_trust_access_service_token" "onepassword_connect" {
  name     = "1Password Connect"
  zone_id  = data.cloudflare_zone.toastboy_co_uk.id
  duration = "60m"
}
