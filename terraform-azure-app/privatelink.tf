# terraform-azure-app/privatelink.tf

###############################################
# 1) Ask CRDB Cloud which Private Endpoint Service(s) exist for this cluster.
#    This also (idempotently) registers provider-side services for the cluster.
###############################################
resource "cockroach_private_endpoint_services" "azure" {
  count      = var.enable_private_dns ? 1 : 0
  cluster_id = var.crdb_cluster_id
}

# Optional: inspect what the API returned (handy while stabilizing Azure)
output "crdb_private_services_raw_azure" {
  value       = var.enable_private_dns ? cockroach_private_endpoint_services.azure[0].services : []
  description = "Raw Azure PE services from CockroachDB Cloud"
}

###############################################
# 2) Select the Azure service for our region & derive DNS zone
###############################################
###############################################
# 2) Select the Azure service for our region & derive DNS zone
###############################################
locals {
  # Normalize potential region fields (the payload varies across environments)
  _azure_services = var.enable_private_dns ? [
    for s in cockroach_private_endpoint_services.azure[0].services : {
      cloud_provider       = try(s.cloud_provider, "")
      region_concat        = lower(join("", [
        try(s.region_name, ""),
        try(s.cloud_region, ""),
        try(s.region, "")
      ]))
      endpoint_service_id  = try(s.endpoint_service_id, try(s.resource_id, ""))
      dns_zone             = try(s.private_dns_zone, try(s.dns_zone, ""))
      full                 = s
    }
  ] : []

  # Filter for AZURE entries whose region string contains our TF region (e.g., "centralus")
  _azure_matches = [
    for s in local._azure_services :
    s if lower(s.cloud_provider) == "azure"
      && strcontains(s.region_concat, lower(var.virtual_network_location))
  ]

  # Pick the first match safely (null if none)
  crdb_azure_service = var.enable_private_dns && length(local._azure_matches) > 0 ? local._azure_matches[0] : null

  # Final DNS zone name: prefer explicit var, else service metadata (if present)
  crdb_private_dns_zone_name = var.enable_private_dns ? coalesce(
    trimspace(var.crdb_private_endpoint_dns),
    trimspace(try(local.crdb_azure_service.dns_zone, "")),
    ""
  ) : ""

  # Convenience extraction with guard (empty string if null)
  _endpoint_service_id = var.enable_private_dns ? trimspace(try(local.crdb_azure_service.endpoint_service_id, "")) : ""
}

# Optional: chosen service (for troubleshooting)
output "crdb_azure_service_selected" {
  value       = var.enable_private_dns ? local.crdb_azure_service : null
  description = "Selected Azure service entry used for Private Endpoint"
}

###############################################
# 3) Private DNS zone + link to our VNet
###############################################
resource "azurerm_private_dns_zone" "crdb" {
  count               = var.enable_private_dns ? 1 : 0
  name                = local.crdb_private_dns_zone_name
  resource_group_name = local.resource_group_name
  tags                = local.tags

  lifecycle {
    precondition {
      condition     = length(local.crdb_private_dns_zone_name) > 0
      error_message = "Azure Private DNS zone name is empty. Set var.crdb_private_endpoint_dns or ensure the CRDB service payload includes a DNS zone."
    }
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "crdb_vnet_link" {
  count                 = var.enable_private_dns ? 1 : 0
  name                  = "${var.owner}-${var.resource_name}-crdb-dnslink"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.crdb[0].name
  virtual_network_id    = azurerm_virtual_network.vm01.id
  registration_enabled  = false
  tags                  = local.tags
}

###############################################
# 4) Azure Private Endpoint (manual approval flow in CRDB Cloud)
###############################################
resource "azurerm_private_endpoint" "crdb_pe" {
  count               = var.enable_private_dns ? 1 : 0
  name                = "${var.owner}-${var.resource_name}-crdb-pe"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  subnet_id           = azurerm_subnet.private[var.pe_subnet_index].id
  tags                = local.tags

  private_service_connection {
    name                           = "${var.owner}-${var.resource_name}-crdb-pe-conn"
    is_manual_connection           = true
    private_connection_resource_id = local._endpoint_service_id
    request_message                = "CRDB PE from ${local.resource_group_name}/${azurerm_virtual_network.vm01.name}"
  }

  private_dns_zone_group {
    name                 = "${var.owner}-${var.resource_name}-crdb-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.crdb[0].id]
  }

  lifecycle {
    precondition {
      condition     = length(local._endpoint_service_id) > 0
      error_message = "Could not derive endpoint_service_id for Azure. Check outputs 'crdb_private_services_raw_azure' and 'crdb_azure_service_selected'."
    }
  }

  depends_on = [
    azurerm_private_dns_zone.crdb,
    azurerm_subnet.private
  ]
}

###############################################
# 5) Apex A record -> Private Endpoint IP
###############################################
resource "azurerm_private_dns_a_record" "crdb_apex" {
  count               = var.enable_private_dns ? 1 : 0
  name                = "@"
  zone_name           = azurerm_private_dns_zone.crdb[0].name
  resource_group_name = local.resource_group_name
  ttl                 = 60
  records             = [
    azurerm_private_endpoint.crdb_pe[0].private_service_connection[0].private_ip_address
  ]
  tags = local.tags
}

###############################################
# Helpful outputs
###############################################
output "crdb_private_endpoint_id" {
  description = "Paste this into CockroachDB Cloud (Private Link -> Validate) for approval."
  value       = var.enable_private_dns ? azurerm_private_endpoint.crdb_pe[0].id : null
}

output "crdb_private_endpoint_ip" {
  description = "Private IP allocated to the Private Endpoint."
  value       = var.enable_private_dns ? azurerm_private_endpoint.crdb_pe[0].private_service_connection[0].private_ip_address : null
}

output "crdb_private_dns_zone" {
  value = var.enable_private_dns ? azurerm_private_dns_zone.crdb[0].name : null
}
