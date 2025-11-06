data "google_compute_zones" "available" {
  region = var.virtual_network_location
}
locals {
  # build the full zone names in order, e.g. ["us-central1-a", ...]
  compute_zones = slice(
    data.google_compute_zones.available.names,
    0,
    var.crdb_nodes
  )

  # first_zone for single-instance pieces (haproxy, app, kafka, etc)
  first_zone = local.compute_zones[0]

  # Common labels
  base_labels = {
    environment = var.virtual_network_location
    owner       = var.owner
  }
  # strip scheme and any trailing slash
  _server_no_scheme = replace(replace(var.cockroach_server, "https://", ""), "http://", "")
  crdb_cloud_url    = trim(local._server_no_scheme, "/")
  app_private_ip    = length(google_compute_instance.app) > 0 ? google_compute_instance.app[0].network_interface[0].network_ip : ""
  bucket_name       = "${var.project_id}-molt-bucket-${var.virtual_network_location}"
}

data "google_compute_image" "compute_image" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

