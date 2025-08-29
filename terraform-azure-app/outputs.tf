# ---------------- Eventhub Outputs ----------------
output "eventhub_namespace_fqdn" {
  description = "Event Hubs namespace FQDN"
  value       = var.deploy_event_hub ? "${azurerm_eventhub_namespace.ehns[0].name}.servicebus.windows.net" : null
}

output "eventhub_name" {
  description = "Event Hub (entity) name"
  value       = try(azurerm_eventhub.hub[0].name, null)
}

output "eventhub_sql_writer_connection_string" {
  description = "Connection string (EntityPath) for SQL writers (Send)"
  value       = try(azurerm_eventhub_authorization_rule.writer_sql[0].primary_connection_string, null)
}

output "eventhub_crdb_reader_connection_string" {
  description = "Connection string (EntityPath) for CRDB readers (Listen)"
  value       = try(azurerm_eventhub_authorization_rule.reader_crdb[0].primary_connection_string, null)
}

output "eventhub_private_endpoint_ip" {
  description = "Private IP for Event Hubs Private Endpoint"
  value       = try(azurerm_private_endpoint.eh[0].private_service_connection[0].private_ip_address, null)
}
# Kafka bootstrap (private, via your Private DNS)
output "eventhub_kafka_bootstrap" {
  description = "Kafka-compatible bootstrap server for Event Hubs"
  value       = var.deploy_event_hub ? "${azurerm_eventhub_namespace.ehns[0].name}.servicebus.windows.net:9093" : null
}

# Kafka Connect worker's namespace-level connection string
output "eventhub_connect_admin_connection_string" {
  description = "Namespace-level SAS connection string for Kafka Connect (manage/send/listen)"
  value       = try(azurerm_eventhub_namespace_authorization_rule.connect_admin[0].primary_connection_string, null)
  sensitive   = true
}


# ------------ sql Outputs: guard with can()/try() -----------------

output "azure_sql_server_name" {
  value       = try(azurerm_mssql_server.sql[0].name, null)
  description = "Azure SQL logical server name"
}

output "azure_sql_database_name" {
  value       = try(azurerm_mssql_database.primary[0].name, null)
  description = "Azure SQL database name"
}

output "azure_sql_private_endpoint_ip" {
  value       = try(azurerm_private_endpoint.sql[0].private_service_connection[0].private_ip_address, null)
  description = "Private IP of SQL Private Endpoint"
}

output "azure_sql_connection_string" {
  value       = var.deploy_azure_sql ? "Server=tcp:${azurerm_mssql_server.sql[0].fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.primary[0].name};Persist Security Info=False;User ID=${var.sql_user_name};Password=${var.sql_user_password};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" : null
  description = "ADO.NET connection string"
}

# -------------------- storage outputs -------------
output "app_container_sas_url" {
  description = "SAS URL for container with full read/write access"
  value       = "${azurerm_storage_account.app_storage.primary_blob_endpoint}${azurerm_storage_container.app_container.name}?${data.azurerm_storage_account_sas.full_access.sas}"
}
