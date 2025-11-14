# terraform-azure-ccloud/azure-single/providers.tf
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
provider "azurerm" {
  features {}
  use_cli         = true
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
provider "cockroach" {
  # api_key = var.cockroach_api_token
  # If your provider supports custom endpoint in your env:
  # server = var.cockroach_server
}
