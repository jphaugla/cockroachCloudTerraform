terraform {
  required_providers {
    cockroach = {
      source  = "cockroachdb/cockroach"
      version = ">= 1.12.2"
    }
    azurerm   = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    local     = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    null      = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

