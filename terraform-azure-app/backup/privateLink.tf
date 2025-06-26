# privatelink.tf

# 1) Ask Cockroach Cloud which PrivateLink service to connect to
resource "cockroach_private_endpoint_services" "azure" {
  cluster_id = var.crdb_cluster_id
}

# 2) Create *only* the Azure Private Endpoint in your VNet/Subnet
resource "azurerm_private_endpoint" "crdb" {
  name                = "${var.owner}-${var.project_name}-crdb-pe"
  location            = var.resource_group_location
  resource_group_name = local.resource_group_name
  subnet_id           = azurerm_subnet.private[0].id

  private_service_connection {
    name                           = "${var.owner}-${var.project_name}-psc"
    private_connection_resource_id = cockroach_private_endpoint_services.azure.services_map[var.virtual_network_location].endpoint_service_id
    is_manual_connection           = true
    request_message = "please approve my private endpoint in [var.virtual_network_location]"
  }
}

# (Optional) If you want DNS integration you can add your own azurerm_private_dns_zone
# block here – CockroachCloud doesn’t currently return it for Azure.
# …leave it out or supply it manually…

