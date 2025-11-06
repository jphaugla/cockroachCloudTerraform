// terraform-gcp/storage.tf

resource "google_storage_bucket" "molt_bucket" {
  name          = "${local.bucket_name}"
  location      = var.virtual_network_location
  force_destroy = true
}

