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

# Default AWS provider for region0
provider "aws" {
  alias  = "region0"
  region = var.aws_region_list[0]
}

provider "aws" {
  alias  = "region1"
  region = var.aws_region_list[1]
}

provider "aws" {
  alias  = "region2"
  region = var.aws_region_list[2]
}

# Also keep an un-aliased default if you have any resources that use it
provider "aws" {
  region = var.aws_region_list[0]
}

# provider "cockroach" {}

# provider "local" {}
