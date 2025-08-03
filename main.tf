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

resource "cloudflare_zero_trust_access_service_token" "onepassword_connect" {
  account_id = var.bootstrap_cloudflare_account_id
  name       = "1Password Connect"
  duration   = "12h"
}

resource "cloudflare_zero_trust_access_policy" "onepassword_connect_service" {
  account_id = var.bootstrap_cloudflare_account_id
  name       = "1Password Connect Service Token Access"
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

  name = "toastboy.co.uk"
}

resource "cloudflare_zero_trust_access_application" "service_application" {
  zone_id = data.cloudflare_zones.toastboy_co_uk.result[0].id

  name   = "onepassword-connect"
  domain = "toastboy.co.uk"

  type             = "self_hosted"
  session_duration = "1h"

  policies = [{
    id         = cloudflare_zero_trust_access_policy.onepassword_connect_service.id
    precedence = 1
  }]
}
