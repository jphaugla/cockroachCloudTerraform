# gcp-single/variables.tf
variable "cockroach_api_token" {
  description = "Cockroach Cloud API token (picks up from TF_VAR_cockroach_api_token)"
  type        = string
}

variable "cockroach_server" {
  description = "Cockroach Cloud API server for the URL(picks up from TF_VAR_cockroach_server)"
  type        = string
}

variable "gcp_account_id" {
  description = "Cockroach Cloud gcp account id (picks up from TF_VAR_gcp_account_id) get this from getClusters account_id"
  type        = string
}
