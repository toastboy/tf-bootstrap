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
  account_id = data.hcp_vault_secrets_app.cloudflare.secrets.accountid
  name       = "1Password Connect"
  duration   = "12h"
}
