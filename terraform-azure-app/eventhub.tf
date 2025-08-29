# ---------------- Namespace ----------------
resource "azurerm_eventhub_namespace" "ehns" {
  count                         = var.deploy_event_hub ? 1 : 0
  name                          = "${var.owner}-${var.resource_name}-ehns"
  location                      = var.virtual_network_location
  resource_group_name           = local.resource_group_name
  sku                           = "Standard"
  capacity                      = 1
  auto_inflate_enabled          = true
  maximum_throughput_units      = 4
  public_network_access_enabled = false
  minimum_tls_version           = "1.2"
  tags                          = local.tags
}
 
# Namespace-level auth rule for Kafka Connect (manage+send+listen)
resource "azurerm_eventhub_namespace_authorization_rule" "connect_admin" {
  count               = var.deploy_event_hub ? 1 : 0
  name                = "connect-admin"
  namespace_name      = azurerm_eventhub_namespace.ehns[0].name
  resource_group_name = local.resource_group_name

  listen = true
  send   = true
  manage = true
}

# ---------------- Event Hub (entity) ----------------
resource "azurerm_eventhub" "hub" {
  count               = var.deploy_event_hub ? 1 : 0
  name                = var.event_hub_name
  namespace_id        = azurerm_eventhub_namespace.ehns[0].id
  partition_count     = 2
  message_retention   = 7
  status              = "Active"
  # NOTE: no tags block on this resource in v4.41.0
}

resource "azurerm_eventhub_consumer_group" "cg" {
  count               = var.deploy_event_hub ? 1 : 0
  name                = "crdb-consumers"
  namespace_name      = azurerm_eventhub_namespace.ehns[0].name
  eventhub_name       = azurerm_eventhub.hub[0].name
  resource_group_name = local.resource_group_name
}

# ---------------- Auth rules ----------------
resource "azurerm_eventhub_authorization_rule" "writer_sql" {
  count               = var.deploy_event_hub ? 1 : 0
  name                = "sql-writer"
  namespace_name      = azurerm_eventhub_namespace.ehns[0].name
  eventhub_name       = azurerm_eventhub.hub[0].name
  resource_group_name = local.resource_group_name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_eventhub_authorization_rule" "reader_crdb" {
  count               = var.deploy_event_hub ? 1 : 0
  name                = "crdb-reader"
  namespace_name      = azurerm_eventhub_namespace.ehns[0].name
  eventhub_name       = azurerm_eventhub.hub[0].name
  resource_group_name = local.resource_group_name
  listen              = true
  send                = false
  manage              = false
}

# ---------------- Private DNS (optional) ----------------
resource "azurerm_private_dns_zone" "eh" {
  count               = var.deploy_event_hub && var.enable_private_dns ? 1 : 0
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = local.resource_group_name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "eh_vnet_link" {
  count                 = var.deploy_event_hub && var.enable_private_dns ? 1 : 0
  name                  = "${var.owner}-${var.resource_name}-ehdns-link"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.eh[0].name
  virtual_network_id    = azurerm_virtual_network.vm01.id
  registration_enabled  = false
  tags                  = local.tags
}

# ---------------- Private Endpoint ----------------
resource "azurerm_private_endpoint" "eh" {
  count               = var.deploy_event_hub ? 1 : 0
  name                = "${var.owner}-${var.resource_name}-eh-pep"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  subnet_id           = azurerm_subnet.private[0].id
  tags                = local.tags

  private_service_connection {
    name                           = "${var.owner}-${var.resource_name}-eh-psc"
    private_connection_resource_id = azurerm_eventhub_namespace.ehns[0].id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.enable_private_dns && var.deploy_event_hub ? [1] : []
    content {
      name                 = "${var.owner}-${var.resource_name}-eh-dnsgrp"
      private_dns_zone_ids = [azurerm_private_dns_zone.eh[0].id]
    }
  }
}
