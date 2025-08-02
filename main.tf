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
