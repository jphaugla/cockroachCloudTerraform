terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    cockroach = {
      source  = "cockroachdb/cockroach"
      version = ">= 1.12.2"
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
