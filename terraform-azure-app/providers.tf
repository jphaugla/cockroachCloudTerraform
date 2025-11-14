# terraform-azure-app/providers.tf
terraform {
  required_providers {
    cockroach = {
      source  = "cockroachdb/cockroach"
      version = ">= 1.15.1"
    }
    azurerm   = {
      source  = "hashicorp/azurerm"
      version = ">= 4.5.0"
    }
    local     = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    null      = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}
