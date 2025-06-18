# provisioning.tf

# Dummy Resource (fallback)
resource "null_resource" "dummy" {}

# Null Resource for Provisioning
resource "null_resource" "provision" {
  # only run the Ansible playbook if run_ansible = true
  count = var.run_ansible ? 1 : 0

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
  -e "setup_migration=${var.setup_migration}" \
  -e "load_balancer_public_ip=${var.crdb_public_endpoint_dns}" \
  -e "load_balancer_private_ip=${var.crdb_private_endpoint_dns}" \
  -e "crdb_version=${var.crdb_version}" \
  -e "crdb_file_location=${var.mount_file_location}" \
  -e "login_username=${local.admin_username}" \
  -e "include_app=${var.include_app}"
EOT
  }

  depends_on = [
    local_file.instances_file,
    aws_vpc_endpoint.crdb,
    aws_instance.app,
    null_resource.dummy,
  ]
}
