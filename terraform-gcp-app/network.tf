// terraform-gcp/network.tf

resource "google_compute_network" "main" {
  name                    = "${var.project_id}-network-${var.virtual_network_location}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main_subnet" {
  name          = "${var.project_id}-subnet-${var.virtual_network_location}"
  ip_cidr_range = var.cidr
  region        = var.virtual_network_location
  network       = google_compute_network.main.id
}
