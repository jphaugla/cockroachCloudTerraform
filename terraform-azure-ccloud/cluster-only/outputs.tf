output "crdb_cluster_id" {
  description = "The ID of the CockroachDB cluster"
  value       = module.my_azure.cluster_id
}

output "crdb_public_endpoint_dns" {
  description = "Public endpoint DNS name for SQL/UI"
  value       = module.my_azure.crdb_public_endpoint_dns
}

output "crdb_cluster_cert" {
value  = module.my_azure.crdb_cluster_cert
}
output "sql_user_name" {
value      = module.my_azure.sql_user_name
}
output "sql_user_password" {
value  = module.my_azure.sql_user_password
}
output "region" {
value         = module.my_azure.region
}
output "owner" {
value                            = module.my_azure.owner
}
output "project_name" {
value                     =  module.my_azure.project_name
}
