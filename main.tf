terraform {
  cloud {
    organization = "toastboy"

    workspaces {
      name = "tf-bootstrap"
    }
  }

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
}

provider "cloudflare" {
  api_token = var.bootstrap_cloudflare_api_token
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "tunnel" {
  account_id = var.bootstrap_cloudflare_account_id
  name       = "bootstrap.toastboy.co.uk"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "tunnel_config" {
  account_id = var.bootstrap_cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.tunnel.id

  config = {
    ingress = [
      {
        hostname = "onepassword-connect.toastboy.co.uk"
        service  = format("http://%s:%d", var.cloudflare_connect_host, var.cloudflare_connect_port)
      },
      {
        service = "http_status:404"
      }
    ],
    warp_routing = {
      enabled = false
    }
  }
}

resource "cloudflare_zero_trust_access_service_token" "onepassword_connect" {
  account_id = var.bootstrap_cloudflare_account_id
  name       = "1Password Connect"
  duration   = "12h"
}

resource "cloudflare_zero_trust_access_policy" "onepassword_connect_service" {
  account_id = var.bootstrap_cloudflare_account_id
  name       = "1Password Connect Service Token: Bootstrap"
  decision   = "non_identity"

  include = [
    {
      service_token = {
        token_id = cloudflare_zero_trust_access_service_token.onepassword_connect.id
      }
    }
  ]
}

data "cloudflare_zones" "toastboy_co_uk" {
  account = {
    id = var.bootstrap_cloudflare_account_id
  }

  name = var.domain
}

resource "cloudflare_dns_record" "record" {
  zone_id = data.cloudflare_zones.toastboy_co_uk.result[0].id
  name    = "onepassword-connect.toastboy.co.uk"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
  ttl     = 1
}

resource "cloudflare_zero_trust_access_application" "service_application" {
  zone_id = data.cloudflare_zones.toastboy_co_uk.result[0].id

  name   = "onepassword-connect"
  domain = var.domain

  type             = "self_hosted"
  session_duration = "1h"

  policies = [{
    id         = cloudflare_zero_trust_access_policy.onepassword_connect_service.id
    precedence = 1
  }]
}
