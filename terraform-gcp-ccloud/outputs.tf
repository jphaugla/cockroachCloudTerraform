# outputs.tf

output "cluster_id" {
  description = "The ID of the CockroachDB cluster (created or existing)"
  value       = local.cluster_id
}

output "sql_endpoint" {
  description = "SQL endpoint (host:port) for region 0"
  value       = length(local.crdb_public_endpoint_dns_list) > 0 ? "${local.crdb_public_endpoint_dns_list[0]}:26257" : ""
}

output "admin_ui_endpoint" {
  description = "Admin UI DNS endpoint for region 0 (when importing and UI DNS is unknown, this mirrors public SQL DNS)"
  value       = length(local.crdb_public_endpoint_dns_list) > 0 ? local.crdb_public_endpoint_dns_list[0] : ""
}

output "crdb_public_endpoint_dns" {
  description = "Public SQL DNS connection string for region 0"
  value       = length(local.crdb_public_endpoint_dns_list) > 0 ? local.crdb_public_endpoint_dns_list[0] : ""
}
