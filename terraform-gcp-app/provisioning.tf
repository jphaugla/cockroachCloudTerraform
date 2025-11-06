# Locals for dynamic values
locals {
  kafka_private_ip     = var.include_kafka == "yes" ? google_compute_instance.kafka[0].network_interface[0].network_ip : "localhost"
  admin_username       = "ubuntu"
}

# Dummy fallback
resource "null_resource" "dummy" {}

# Null resource to run Ansible
resource "null_resource" "provision" {
  count = var.run_ansible ? 1 : 0

  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    google_compute_instance.kafka,
    google_compute_instance.app,
    local_file.instances_file,
    null_resource.dummy,
  ]

  provisioner "local-exec" {
    working_dir = var.playbook_working_directory

    command = <<EOF
ansible-playbook \
  -i "${var.playbook_instances_inventory_file}" \
  --private-key "${var.ssh_private_key}" \
  playbook.yml ${var.ansible_verbosity_switch} \
  -e db_admin_user="${var.sql_user_name}" \
  -e db_admin_password="${var.sql_user_password}" \
  -e crdb_version="${var.crdb_version}" \
  -e region="${var.virtual_network_location}" \
  -e include_kafka="${var.include_kafka}" \
  -e setup_migration="${var.setup_migration}" \
  -e kafka_internal_ip="${local.kafka_private_ip}" \
  -e app_private_ip=${local.app_private_ip} \
  -e crdb_file_location="${var.crdb_file_location}" \
  -e login_username="${local.admin_username}" \
  -e kafka_username=ubuntu \
  -e include_app="${var.include_app}" \
  -e do_crdb_init="${var.do_crdb_init}" \
  -e "cluster_id=${var.crdb_cluster_id}" \
  -e "cockroach_api_token=${var.cockroach_api_token}" \
  -e "cockroach_server=${var.cockroach_server}" \
  -e "crdb_cloud_url=${local.crdb_cloud_url}" \
  -e "cloud_provider=gcp" \
  -e "bucket_name=${local.bucket_name}" \
  -e load_balancer_public_ip="${var.crdb_public_endpoint_dns}" \
  -e load_balancer_private_ip="${var.crdb_private_endpoint_dns}"
EOF
  }
}

