# terraform-azure-ccloud/azure-single/variables.tf
variable "cockroach_api_token" {
  description = "Cockroach Cloud API token (picks up from TF_VAR_cockroach_api_token)"
  type        = string
}

variable "cockroach_server" {
  description = "Cockroach Cloud API server for the URL(picks up from TF_VAR_cockroach_server)"
  type        = string
}

variable "subscription_id" {
  description = "Azure Cloud subscription ID(picks up from TF_VAR_subscription_id) only needed for byoc"
  type        = string
}

variable "tenant_id" {
  description = "Azure Cloud tenant ID(picks up from TF_VAR_tenant_id) only needed for byoc"
  type        = string
}
