// terraform-gcp/terraform.tf
terraform {
  required_providers {
    cockroach = {
      source  = "cockroachdb/cockroach"
      version = ">= 1.15.1"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    null = {
      source = "hashicorp/null"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}

