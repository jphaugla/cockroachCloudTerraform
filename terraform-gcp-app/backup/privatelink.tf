# terraform-gcp-app/privatelink.tf
# Register the PSC endpoint (your Forwarding Rule) with Cockroach

###############################################
# 1) Discover CRDB PSC services for this cluster
###############################################
resource "cockroach_private_endpoint_services" "gcp" {
  count      = var.enable_privatelink ? 1 : 0
  cluster_id = var.crdb_cluster_id
}

# Optional: keep during bring-up to see exact fields the provider returns
output "crdb_private_services_map_raw" {
  value       = var.enable_privatelink ? cockroach_private_endpoint_services.gcp[0].services_map : {}
  description = "Region->service map from CockroachDB; inspect to confirm which field is the service attachment URL"
}

###############################################
# 2) Normalize the Service Attachment URL for this region
###############################################
locals {
  # Pick this region's map entry (fallback to first if not found)
  _psc_entry = var.enable_privatelink ? lookup(
    cockroach_private_endpoint_services.gcp[0].services_map,
    var.virtual_network_location,
    values(cockroach_private_endpoint_services.gcp[0].services_map)[0]
  ) : null

  # Only evaluate when privatelink is enabled
  _sa_from_entry = var.enable_privatelink ? coalesce(
    try(local._psc_entry.service_attachment, null),  # preferred
    try(local._psc_entry.target_service,  null),     # alternate
    try(local._psc_entry.name,            null)      # sometimes only short name
  ) : null

  _sa_is_selflink = var.enable_privatelink && local._sa_from_entry != null && can(
    regex("^projects/.+/regions/.+/serviceAttachments/.+$", local._sa_from_entry)
  )

  _producer_project = var.enable_privatelink ? coalesce(
    try(local._psc_entry.producer_project, null),
    try(local._psc_entry.project,          null),
    length(var.psc_producer_project_id) > 0 ? var.psc_producer_project_id : null
  ) : null

  # Final serviceAttachment target for the Forwarding Rule
  crdb_psc_target_service = var.enable_privatelink ? (
    local._sa_is_selflink ? local._sa_from_entry :
    (
      local._producer_project != null && local._sa_from_entry != null
      ? "projects/${local._producer_project}/regions/${var.virtual_network_location}/serviceAttachments/${local._sa_from_entry}"
      : null
    )
  ) : null
}

###############################################
# 3) Reserve an internal IP for the PSC endpoint
###############################################
resource "google_compute_address" "crdb_psc_ip" {
  count        = var.enable_privatelink ? 1 : 0
  name         = "${var.project_id}-${var.virtual_network_location}-crdb-psc-ip"
  region       = var.virtual_network_location
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.main_subnet.id
  purpose      = "GCE_ENDPOINT"
}

###############################################
# 4) Create the PSC endpoint (Forwarding Rule)
###############################################
resource "google_compute_forwarding_rule" "crdb_psc" {
  count                   = var.enable_privatelink ? 1 : 0
  name                    = "${var.project_id}-${var.virtual_network_location}-crdb-psc"
  region                  = var.virtual_network_location
  load_balancing_scheme   = ""   # required for PSC endpoint
  target                  = local.crdb_psc_target_service
  network                 = google_compute_network.main.id
  subnetwork              = google_compute_subnetwork.main_subnet.id
  ip_address              = google_compute_address.crdb_psc_ip[0].self_link
  allow_psc_global_access = var.allow_psc_global_access

  labels = {
    owner  = var.project_id
    region = var.virtual_network_location
  }
}

###############################################
# 5) Optional: Private DNS inside your VPC
###############################################
# IMPORTANT: keep 'count' purely var-driven so it's always plan-time known
# We do not use locals in the count expression.
resource "google_dns_managed_zone" "crdb_private_zone" {
  count      = (var.enable_privatelink && var.enable_private_dns && length(trimspace(var.crdb_private_endpoint_dns)) > 0) ? 1 : 0

  name       = replace("${var.project_id}-${var.virtual_network_location}-crdb-priv-zone", "_", "-")

  # Ensure trailing dot, computed from the var only
  # If var already ends with '.', keep it; else add '.'
  dns_name   = endswith(trimspace(var.crdb_private_endpoint_dns), ".")
               ? trimspace(var.crdb_private_endpoint_dns)
               : "${trimspace(var.crdb_private_endpoint_dns)}."

  visibility = "private"

  private_visibility_config {
    networks { network_url = google_compute_network.main.id } # id is a URL-form here
  }
}

# Record uses the zone if it exists; count mirrors the zone's count
resource "google_dns_record_set" "crdb_private_a" {
  count        = google_dns_managed_zone.crdb_private_zone.count

  # Same FQDN expression; keep consistent with the zone
  name         = endswith(trimspace(var.crdb_private_endpoint_dns), ".")
                 ? trimspace(var.crdb_private_endpoint_dns)
                 : "${trimspace(var.crdb_private_endpoint_dns)}."

  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.crdb_private_zone[0].name
  rrdatas      = [google_compute_address.crdb_psc_ip[0].address]
}

###############################################
# Outputs
###############################################
output "crdb_psc_ip" {
  value       = var.enable_privatelink ? google_compute_address.crdb_psc_ip[0].address : null
  description = "Internal IP of the PSC endpoint to CockroachDB"
}

output "crdb_psc_forwarding_rule" {
  value       = var.enable_privatelink ? google_compute_forwarding_rule.crdb_psc[0].name : null
  description = "PSC forwarding rule name"
}
