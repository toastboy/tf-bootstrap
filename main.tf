terraform {
  cloud {
    organization = "toastboy"

    workspaces {
      name = "tf-bootstrap"
    }
  }

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.68.2"
    }

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

provider "tfe" {
  token = var.bootstrap_tfe_token
}

provider "cloudflare" {
  api_token = var.bootstrap_cloudflare_api_token
}

provider "onepassword" {
  url   = format("https://%s.%s", var.subdomain, var.domain)
  token = var.bootstrap_onepassword_connect_token
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "tunnel" {
  account_id = var.bootstrap_cloudflare_account_id
  name       = format("bootstrap.%s", var.domain)
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "tunnel_config" {
  account_id = var.bootstrap_cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.tunnel.id

  config = {
    ingress = [
      {
        hostname = format("%s.%s", var.subdomain, var.domain)
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
  duration   = "24h"
}

data "tfe_workspace" "tf-bootstrap" {
  name         = "tf-bootstrap"
  organization = "toastboy"
}

resource "tfe_variable" "test_cloudflare_zero_trust_access_service_token_client_id" {
  key          = "test_cloudflare_zero_trust_access_service_token_client_id"
  value_wo     = cloudflare_zero_trust_access_service_token.onepassword_connect.client_id
  category     = "terraform"
  workspace_id = data.tfe_workspace.tf-bootstrap.id
  description  = "See https://registry.terraform.io/providers/cloudflare/cloudflare/5.4.0/docs/resources/zero_trust_access_service_token"
}

resource "tfe_variable" "test_cloudflare_zero_trust_access_service_token_client_secret" {
  key          = "test_cloudflare_zero_trust_access_service_token_client_secret"
  value_wo     = cloudflare_zero_trust_access_service_token.onepassword_connect.client_secret
  category     = "terraform"
  workspace_id = data.tfe_workspace.tf-bootstrap.id
  description  = "See https://registry.terraform.io/providers/cloudflare/cloudflare/5.4.0/docs/resources/zero_trust_access_service_token"
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
  name    = format("%s.%s", var.subdomain, var.domain)
  content = "${cloudflare_zero_trust_tunnel_cloudflared.tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
  ttl     = 1
}

resource "cloudflare_zero_trust_access_application" "service_application" {
  zone_id = data.cloudflare_zones.toastboy_co_uk.result[0].id

  name   = var.subdomain
  domain = var.domain

  type             = "self_hosted"
  session_duration = "24h"

  policies = [{
    id         = cloudflare_zero_trust_access_policy.onepassword_connect_service.id
    precedence = 1
  }]
}

data "onepassword_vault" "op_connect" {
  name = "op-connect"
}

resource "onepassword_item" "demo_password" {
  vault = data.onepassword_vault.op_connect.name

  title    = "Demo Password Recipe"
  category = "password"

  password_recipe {
    length  = 40
    symbols = false
  }
}
