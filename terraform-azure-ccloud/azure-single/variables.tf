variable "cockroach_api_token" {
  description = "Cockroach Cloud API token (picks up from TF_VAR_cockroach_api_token)"
  type        = string
}

variable "cockroach_api_key" {
  description = "Cockroach Cloud API key (alternative to token)"
  type        = string
}
