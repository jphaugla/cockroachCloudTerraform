# provisioning.tf

# Dummy Resource (fallback)
resource "null_resource" "dummy" {}

# Null Resource for Provisioning
resource "null_resource" "provision" {
  count = var.run_ansible && var.enable_private_dns ? 1 : 0

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    working_dir = var.playbook_working_directory
    command = <<EOT
ansible-playbook \
  -i '${var.playbook_instances_inventory_file}' \
  --private-key '${var.ssh_private_key}' \
  playbook.yml ${var.ansible_verbosity_switch} \
  -e "db_admin_user=${var.sql_user_name}" \
  -e "db_admin_password=${var.sql_user_password}" \
  -e "region=${var.aws_region}" \
  -e include_kafka=${var.include_kafka} \
  -e kafka_internal_ip=${local.kafka_private_ip} \
  -e app_private_ip=${local.app_private_ip} \
  -e kafka_username=ubuntu \
  -e "setup_migration=${var.setup_migration}" \
  -e "cluster_id=${var.crdb_cluster_id}" \
  -e "load_balancer_public_ip=${var.crdb_public_endpoint_dns}" \
  -e "load_balancer_private_ip=${var.crdb_private_endpoint_dns}" \
  -e "crdb_version=${var.crdb_version}" \
  -e "crdb_file_location=${var.mount_file_location}" \
  -e "cockroach_api_token=${var.cockroach_api_token}" \
  -e "login_username=${local.admin_username}" \
  -e "cockroach_server=${var.cockroach_server}" \
  -e "crdb_cloud_url=${local.crdb_cloud_url}" \
  -e "cloud_provider="aws" \
  -e "bucket_name=${local.bucket_name}" \
  -e "include_app=${var.include_app}"
EOT
  }

  # STATIC list — Terraform is happy
  depends_on = [
    local_file.instances_file,
    aws_vpc_endpoint.crdb,
    aws_instance.app,
    null_resource.dummy,
    aws_instance.kafka,      # safe even when count = 0
  ]
}

