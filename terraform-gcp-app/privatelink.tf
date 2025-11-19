# terraform-gcp-app/privatelink.tf
# Private Service Connect endpoint for CockroachDB Cloud (GCP)
#
# Expected inputs (declare in variables.tf or via TF_VAR_*):
#   enable_privatelink            (bool)
#   project_id                    (string)
#   virtual_network_location      (string)   # e.g. "us-central1"
#   allow_psc_global_access       (bool)
#   crdb_cluster_id               (string)   # CockroachDB Cloud cluster ID
#   psc_producer_project_id       (string)   # Cockroach producer project (your gcp_account_id from CRDB API)
#   crdb_private_endpoint_dns     (string)   # e.g. "db.internal" (optional; used when enable_privatelink = true)
#
# Required existing resources:
#   google_compute_network.main
#   google_compute_subnetwork.main_subnet

###############################################
# 1) Discover CRDB PSC services for this cluster
###############################################
resource "cockroach_private_endpoint_services" "gcp" {
  count      = var.enable_privatelink ? 1 : 0
  cluster_id = var.crdb_cluster_id
}

# Optional: inspect what CRDB returns (handy for troubleshooting)
output "crdb_private_services_map_raw" {
  value       = var.enable_privatelink ? cockroach_private_endpoint_services.gcp[0].services_map : {}
  description = "Region->service map from CockroachDB"
}

###############################################
# 2) Build the target serviceAttachment selfLink
###############################################
locals {
  # Pick this region's entry; if not found, fallback to the first entry
  _psc_entry = var.enable_privatelink ? lookup(
    cockroach_private_endpoint_services.gcp[0].services_map,
    var.virtual_network_location,
    values(cockroach_private_endpoint_services.gcp[0].services_map)[0]
  ) : null

  # Short service-attachment name like "sa-abc123"
  _sa_short    = var.enable_privatelink ? try(local._psc_entry.name, null) : null

  # Prefer any full selfLink the provider may give (nice-to-have)
  _sa_selflink = var.enable_privatelink ? try(local._psc_entry.service_attachment, null) : null

  # Final target: if we got a full selfLink, use it; else build from producer project + region + short name
  crdb_psc_target_service = var.enable_privatelink ? (
    (local._sa_selflink != null && can(regex("^projects/.+/regions/.+/serviceAttachments/.+$", local._sa_selflink)))
      ? local._sa_selflink
      : "projects/${var.psc_producer_project_id}/regions/${var.virtual_network_location}/serviceAttachments/${local._sa_short}"
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
# 5) Optional: Private DNS inside your VPC (plan-safe keys)
###############################################
# Make the for_each keys STATIC so Terraform can always plan,
# and read the DNS name directly from variables in the body.

# helper local: true iff we want DNS
locals {
  _dns_wanted = var.enable_privatelink 
}

resource "google_dns_managed_zone" "crdb_private_zone" {
  # Static key map when enabled; empty map when disabled.
  for_each = local._dns_wanted ? { zone = true } : {}

  name       = replace("${var.project_id}-${var.virtual_network_location}-crdb-priv-zone", "_", "-")
  # Use the var directly; not from for_each keys/values.
  dns_name   = endswith(var.crdb_private_endpoint_dns, ".") ? var.crdb_private_endpoint_dns : "${var.crdb_private_endpoint_dns}."
  visibility = "private"

  private_visibility_config {
    networks { network_url = google_compute_network.main.self_link }
  }
}
###############################################
# 6) Outputs
###############################################
output "crdb_psc_ip" {
  value       = var.enable_privatelink ? google_compute_address.crdb_psc_ip[0].address : null
  description = "Internal IP of the PSC endpoint to CockroachDB"
}

output "crdb_psc_forwarding_rule" {
  value       = var.enable_privatelink ? google_compute_forwarding_rule.crdb_psc[0].name : null
  description = "PSC forwarding rule name"
}
