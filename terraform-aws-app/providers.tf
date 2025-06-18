# modules/crdb-region-0/terraform {
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.29.0"
    }
    cockroach = {
      source  = "cockroachdb/cockroach"
      version = ">= 1.12.2"
    }
  }
}
# }

