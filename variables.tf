variable "bootstrap_tfe_token" {
  description = "The Terraform Enterprise token"
  type        = string
}

variable "bootstrap_cloudflare_account_id" {
  description = "The Cloudflare account ID"
  type        = string
  default     = "ff3cf12467f08052d7d8d28cf3fc9369"
}

variable "bootstrap_cloudflare_api_token" {
  description = "The API token for Cloudflare"
  type        = string
}

variable "bootstrap_onepassword_connect_token" {
  description = "The 1Password Connect token"
  type        = string
}

variable "subdomain" {
  description = "The subdomain for the 1Password Connect service"
  type        = string
  default     = "onepassword-connect"
}

variable "domain" {
  description = "The domain for the Cloudflare zone"
  type        = string
  default     = "toastboy.co.uk"
}

variable "cloudflare_connect_host" {
  description = "IP address of the 1Password Connect server"
  type        = string
  default     = "172.16.16.100"
}

variable "cloudflare_connect_port" {
  description = "Port of the 1Password Connect server"
  type        = number
  default     = 8580
}
