# backend.tf
terraform {
  backend "s3" {
    bucket = "terraform-state-backend"
    key    = "talos-cluster/terraform.tfstate"
    region = "auto"

    # Custom R2 Endpoint
    endpoints = {
      s3 = "https://5cd98fb1b747655ecb07625e3870415c.r2.cloudflarestorage.com"
    }

    # Required flags for Cloudflare R2 compatibility
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}
