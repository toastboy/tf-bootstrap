terraform {
  required_providers {
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

provider "onepassword" {
  url   = var.op_connect_host
  token = var.op_connect_token
}
