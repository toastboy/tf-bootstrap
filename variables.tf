variable "bootstrap_cloudflare_account_id" {
  description = "The Cloudflare account ID"
  type        = string
}

variable "bootstrap_cloudflare_api_token" {
  description = "The API token for Cloudflare"
  type        = string
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
