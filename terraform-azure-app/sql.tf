############################################
# Azure SQL (Server + DB) with Private Link
############################################

resource "azurerm_mssql_server" "sql" {
  count                        = var.deploy_azure_sql ? 1 : 0
  name                         = "${var.owner}-${var.resource_name}-sqlsrv"
  resource_group_name          = local.resource_group_name
  location                     = var.virtual_network_location
  version                      = "12.0"
  administrator_login          = var.sql_user_name
  administrator_login_password = local.sql_user_password

  minimum_tls_version           = "1.2"
  public_network_access_enabled = false

  tags = local.tags
}

resource "azurerm_mssql_database" "primary" {
  count      = var.deploy_azure_sql ? 1 : 0
  name       = "${var.owner}-${var.resource_name}-sqldb"
  server_id  = azurerm_mssql_server.sql[0].id
  sku_name   = var.sql_db_sku_name
  tags       = local.tags
}

resource "azurerm_private_dns_zone" "sql" {
  count = var.deploy_azure_sql && var.enable_private_dns ? 1 : 0
  name                = "privatelink.database.windows.net"
  resource_group_name = local.resource_group_name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_vnet_link" {
  count = var.deploy_azure_sql && var.enable_private_dns ? 1 : 0
  name                  = "${var.owner}-${var.resource_name}-sqldns-link"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql[0].name
  virtual_network_id    = azurerm_virtual_network.vm01.id
  registration_enabled  = false
  tags                  = local.tags
}

resource "azurerm_private_endpoint" "sql" {
  count               = var.deploy_azure_sql ? 1 : 0
  name                = "${var.owner}-${var.resource_name}-sql-pep"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  subnet_id           = azurerm_subnet.private[0].id
  tags                = local.tags

  private_service_connection {
    name                           = "${var.owner}-${var.resource_name}-sql-psc"
    private_connection_resource_id = azurerm_mssql_server.sql[0].id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.enable_private_dns && var.deploy_azure_sql ? [1] : []
    content {
      name                 = "${var.owner}-${var.resource_name}-sql-dnsgrp"
      private_dns_zone_ids = [azurerm_private_dns_zone.sql[0].id]
    }
  }
}
