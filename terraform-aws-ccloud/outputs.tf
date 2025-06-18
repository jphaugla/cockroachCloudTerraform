# outputs.tf

output "cluster_id" {
  description = "The ID of the CockroachDB cluster"
  value       = cockroach_cluster.advanced.id
}

output "sql_endpoint" {
  description = "SQL endpoint (host:port) for the cluster"
  value       = "${cockroach_cluster.advanced.regions[0].sql_dns}:26257"
}

output "admin_ui_endpoint" {
  description = "Admin UI DNS endpoint for the cluster"
  value       = cockroach_cluster.advanced.regions[0].ui_dns
}

output "crdb_private_endpoint_dns" {
  description = "internal dns connection string"
  value = cockroach_cluster.advanced.regions[0].internal_dns
}

output "crdb_public_endpoint_dns" {
  description = "public dns connection string"
  value = cockroach_cluster.advanced.regions[0].sql_dns
}

# — OR — if you prefer using a data source:
 data "cockroach_cluster" "advanced_fetch" {
   id = cockroach_cluster.advanced.id
}

# output "crdb_private_endpoint_dns" {
#   value = data.cockroach_cluster.advanced_fetch.sql_dns
# }

