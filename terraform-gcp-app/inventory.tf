// terraform-gcp/inventory.tf
resource "local_file" "instances_file" {
  filename = var.instances_inventory_file

  content = templatefile(
    "${path.module}/templates/inventory.tpl",
    {
      kafka_public_ip       = length(google_compute_instance.kafka) > 0 ? google_compute_instance.kafka[0].network_interface[0].access_config[0].nat_ip : "null"
      kafka_private_ip      = length(google_compute_instance.kafka) > 0 ? google_compute_instance.kafka[0].network_interface[0].network_ip : "null"

      app_public_ip         = length(google_compute_instance.app) > 0 ? google_compute_instance.app[0].network_interface[0].access_config[0].nat_ip : ""
      app_private_ip        = length(google_compute_instance.app) > 0 ? google_compute_instance.app[0].network_interface[0].network_ip : ""
      app_private_ips       = join("\n", google_compute_instance.app[*].network_interface[0].network_ip)
      app_public_ips        = join("\n", google_compute_instance.app[*].network_interface[0].access_config[0].nat_ip)
      app_public_ips_un     = join("\n", [for inst in google_compute_instance.app : "${inst.network_interface[0].access_config[0].nat_ip} ansible_user=${local.admin_username}"])

      ssh_user              = local.admin_username

      all_public_ips_un     = join("\n", flatten([
        [for inst in google_compute_instance.app  : "${inst.network_interface[0].access_config[0].nat_ip} ansible_user=${local.admin_username}"]
      ]))

      all_public_ips        = join("\n", compact([
        join("\n", google_compute_instance.app[*].network_interface[0].access_config[0].nat_ip)
      ]))
    }
  )

  depends_on = [
    google_compute_instance.kafka,
    google_compute_instance.app,
  ]
}

