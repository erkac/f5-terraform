terraform {
  required_providers {
    bigip = {
      source = "f5networks/bigip"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
  required_version = ">= 0.13"
}
