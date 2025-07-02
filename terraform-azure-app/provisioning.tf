# provisioning.tf

# Dummy Resource (fallback)
resource "null_resource" "dummy" {}

# Null Resource for Provisioning
resource "null_resource" "provision" {
  count = var.run_ansible ? 1 : 0

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    working_dir = var.playbook_working_directory

    command = <<EOT
ansible-playbook \
  -u "${var.login_username}" \
  -i "${var.playbook_instances_inventory_file}" \
  --private-key "${var.ssh_private_key}" \
  playbook.yml "${var.ansible_verbosity_switch}" \
  -e "db_admin_user=${var.sql_user_name}" \
  -e "db_admin_password=${var.sql_user_password}" \
  -e "region=${var.virtual_network_location}" \
  -e "setup_migration=${var.setup_migration}" \
  -e "load_balancer_public_ip=${var.crdb_public_endpoint_dns}" \
  -e "load_balancer_private_ip=${var.crdb_private_endpoint_dns}" \
  -e "crdb_version=${var.crdb_version}" \
  -e "crdb_file_location=${var.crdb_file_location}" \
  -e "login_username=${var.login_username}" \
  -e "include_app=${var.include_app}" \
  -e "resource_group=${local.resource_group_name}" \
  -e "vnet_name=${azurerm_virtual_network.vm01.name}" \
  -e "subnet_name=${azurerm_subnet.private[0].name}" \
  -e "cluster_id=${var.crdb_cluster_id}" \
  -e "owner=${var.owner}" \
  -e "pe_service_id=${var.pe_service_id}" \
  -e "cockroach_api_token=${var.cockroach_api_token}" \
  -e "cockroach_api_key=${var.cockroach_api_key}"
EOT
  }

  depends_on = [
    local_file.instances_file,
    azurerm_linux_virtual_machine.app,
    null_resource.dummy,
  ]
}
