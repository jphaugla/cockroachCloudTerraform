# terraform-azure-ccloud/providers.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.5.0"
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
