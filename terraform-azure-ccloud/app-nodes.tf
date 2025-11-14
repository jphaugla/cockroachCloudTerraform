# terraform-azure-cclous/app-nodes.tf
#
# This file instantiates the azure app module up to 3 regions.
# - Assumes the child module ../terraform-azure-app does NOT declare provider blocks.
# - Region enablement is controlled by local.region_count and var.region_list[*].
# - IMPORTANT: Child module must declare variables:
#     use_trusted_owners (bool), 
#     crdb_private_endpoint_dns (string), ssh_key_resource_group (string), ssh_private_key (string),
#     plus the others referenced below.

# ──────────────────────────────────────────────────────────────────────────────
# 2) Module for Region 0 (Primary)
# ──────────────────────────────────────────────────────────────────────────────
module "crdb-region-0" {
  count  = local.region_count > 0 ? 1 : 0
  source = "../terraform-azure-app"

  # Behavior / metadata
  use_trusted_owners = var.use_trusted_owners
  owner              = var.owner

  # CockroachDB cluster inputs
  cockroach_server          = var.cockroach_server
  crdb_cluster_id           = local.cluster_id
  cockroach_api_token       = var.cockroach_api_token
  crdb_cluster_cert         = local.crdb_cluster_cert
  crdb_version              = var.crdb_version
  crdb_private_endpoint_dns         = local.crdb_private_endpoint_dns_list[0]  # REQUIRED by child
  crdb_public_endpoint_dns  = local.crdb_public_endpoint_dns_list[0]
  enable_private_dns       = var.enable_private_dns
  run_ansible       = var.run_ansible
  playbook_instances_inventory_file  = "../terraform-azure-app/inventory-${var.region_list[0]}"
  playbook_working_directory         = "../../ansible"
  instances_inventory_file           = "../../terraform-azure-app/inventory-${var.region_list[0]}"
  instances_inventory_directory      = "temp"
  inventory_template_file            = "templates/inventory.tpl"

  # Azure & Networking
  virtual_network_location  = var.region_list[0]       # e.g. "centralus"
  virtual_network_cidr      = var.vpc_cidr_list[0]     # child expects VN CIDR under this name
  netskope_ips              = var.netskope_ips

  # Application Node
  app_vm_size     = var.app_vm_size                    # e.g. "Standard_B8ms"
  my_ip_address   = var.my_ip_address

  # SSH (REQUIRED by child)
  ssh_key_resource_group = var.ssh_key_resource_group
  ssh_private_key           = var.ssh_private_key
  ssh_key_name           = var.ssh_key_name

  # Kafka
  include_kafka       = var.include_kafka
  kafka_instance_type = var.kafka_instance_type

  # SQL User (if the child uses these)
  sql_user_name     = var.sql_user_name
  sql_user_password = var.sql_user_password
}

# ──────────────────────────────────────────────────────────────────────────────
# 3) Module for Region 1 (Secondary)
# ──────────────────────────────────────────────────────────────────────────────
module "crdb-region-1" {
  count  = local.region_count > 1 ? 1 : 0
  source = "../terraform-azure-app"

  use_trusted_owners = var.use_trusted_owners
  owner              = var.owner

  cockroach_server          = var.cockroach_server
  crdb_cluster_id           = local.cluster_id
  cockroach_api_token       = var.cockroach_api_token
  crdb_cluster_cert         = local.crdb_cluster_cert
  crdb_version              = var.crdb_version
  crdb_private_endpoint_dns         = local.crdb_private_endpoint_dns_list[1]
  crdb_public_endpoint_dns  = local.crdb_public_endpoint_dns_list[1]
  enable_private_dns       = var.enable_private_dns
  run_ansible       = var.run_ansible
  playbook_instances_inventory_file  = "../terraform-azure-app/inventory-${var.region_list[1]}"
  playbook_working_directory         = "../../ansible"
  instances_inventory_file           = "../../terraform-azure-app/inventory-${var.region_list[1]}"
  instances_inventory_directory      = "temp"
  inventory_template_file            = "templates/inventory.tpl"

  virtual_network_location  = var.region_list[1]
  virtual_network_cidr      = var.vpc_cidr_list[1]
  netskope_ips              = var.netskope_ips

  app_vm_size     = var.app_vm_size
  my_ip_address   = var.my_ip_address

  ssh_key_resource_group = var.ssh_key_resource_group
  ssh_private_key           = var.ssh_private_key
  ssh_key_name           = var.ssh_key_name

  include_kafka       = var.include_kafka
  kafka_instance_type = var.kafka_instance_type

  sql_user_name     = var.sql_user_name
  sql_user_password = var.sql_user_password
}

# ──────────────────────────────────────────────────────────────────────────────
# 4) Module for Region 2 (Tertiary)
# ──────────────────────────────────────────────────────────────────────────────
module "crdb-region-2" {
  count  = local.region_count > 2 ? 1 : 0
  source = "../terraform-azure-app"

  use_trusted_owners = var.use_trusted_owners
  owner              = var.owner

  cockroach_server          = var.cockroach_server
  crdb_cluster_id           = local.cluster_id
  cockroach_api_token       = var.cockroach_api_token
  crdb_cluster_cert         = local.crdb_cluster_cert
  crdb_version              = var.crdb_version
  crdb_private_endpoint_dns = local.crdb_private_endpoint_dns_list[2]
  crdb_public_endpoint_dns  = local.crdb_public_endpoint_dns_list[2]
  enable_private_dns       = var.enable_private_dns
  run_ansible       = var.run_ansible
  playbook_instances_inventory_file  = "../terraform-azure-app/inventory-${var.region_list[2]}"
  playbook_working_directory         = "../../ansible"
  instances_inventory_file           = "../../terraform-azure-app/inventory-${var.region_list[2]}"
  instances_inventory_directory      = "temp"
  inventory_template_file            = "templates/inventory.tpl"

  virtual_network_location  = var.region_list[2]
  virtual_network_cidr      = var.vpc_cidr_list[2]
  netskope_ips              = var.netskope_ips

  app_vm_size     = var.app_vm_size
  my_ip_address   = var.my_ip_address

  ssh_key_resource_group = var.ssh_key_resource_group
  ssh_private_key           = var.ssh_private_key
  ssh_key_name           = var.ssh_key_name

  include_kafka       = var.include_kafka
  kafka_instance_type = var.kafka_instance_type

  sql_user_name     = var.sql_user_name
  sql_user_password = var.sql_user_password
}
