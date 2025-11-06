terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
    cockroach = {
      source  = "cockroachdb/cockroach"
      version = ">= 1.15.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "cockroach" {
  apikey = var.cockroach_api_token
}

# single, un‑aliased provider for standalone use
provider "google" {
  project     = var.project_id
  region      = var.virtual_network_location
  credentials = file(var.gcp_credentials_file)
}
