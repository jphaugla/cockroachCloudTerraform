# providers.tf

terraform {
  required_providers {
    cockroach = {
      source  = "cockroachdb/cockroach"
      version = ">= 1.12.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}
