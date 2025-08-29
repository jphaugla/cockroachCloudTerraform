# ---- Event Hub passthrough ----
output "eventhub_namespace_fqdn" {
  description = "Event Hubs namespace FQDN"
  value       = module.app_nodes.eventhub_namespace_fqdn
}

output "eventhub_name" {
  description = "Event Hub (entity) name"
  value       = module.app_nodes.eventhub_name
}

output "eventhub_sql_writer_connection_string" {
  description = "Connection string (EntityPath) for SQL writers (Send)"
  value       = nonsensitive(module.app_nodes.eventhub_sql_writer_connection_string)
}

output "eventhub_crdb_reader_connection_string" {
  description = "Connection string (EntityPath) for CRDB readers (Listen)"
  value       = nonsensitive(module.app_nodes.eventhub_crdb_reader_connection_string)
}

output "eventhub_private_endpoint_ip" {
  description = "Private IP for Event Hubs Private Endpoint"
  value       = module.app_nodes.eventhub_private_endpoint_ip
}

output "eventhub_kafka_bootstrap" {
  value       = module.app_nodes.eventhub_kafka_bootstrap
  description = "Kafka-compatible bootstrap"
}

output "eventhub_connect_admin_connection_string" {
  value       = nonsensitive(module.app_nodes.eventhub_connect_admin_connection_string)
  description = "Namespace-level SAS for Kafka Connect"
}

# ---- Azure SQL passthrough ----
output "azure_sql_server_name" {
  value       = module.app_nodes.azure_sql_server_name
  description = "Azure SQL logical server name"
}

output "azure_sql_database_name" {
  value       = module.app_nodes.azure_sql_database_name
  description = "Azure SQL database name"
}

output "azure_sql_private_endpoint_ip" {
  value       = module.app_nodes.azure_sql_private_endpoint_ip
  description = "Private IP of SQL Private Endpoint"
}

output "azure_sql_connection_string" {
  value       = module.app_nodes.azure_sql_connection_string
  description = "ADO.NET connection string"
}

# ---- Storage passthrough ----
output "app_container_sas_url" {
  description = "SAS URL for container with full read/write access"
  value       = nonsensitive(module.app_nodes.app_container_sas_url)
}

