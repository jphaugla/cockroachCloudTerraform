variable "cockroach_api_token" {
  description = "Cockroach Cloud API token (picks up from TF_VAR_cockroach_api_token)"
  type        = string
}
variable "cluster_id" {
  description = "Cockroach Cloud API token (picks up from TF_VAR_cluster_id)"
  type        = string
}
variable "cockroach_server" {
  description = "Cockroach Cloud API server for the URL(picks up from TF_VAR_cockroach_server)"
  type        = string
}
