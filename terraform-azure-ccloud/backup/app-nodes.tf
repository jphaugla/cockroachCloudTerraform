# app-nodes.tf

# ──────────────────────────────────────────────────────────────────────────────
# 1) AWS provider aliases for each region
# ──────────────────────────────────────────────────────────────────────────────
provider "azurerm" {
  alias  = "region0"
  region = var.region_list[0]
}
provider "azurerm" {
  alias  = "region1"
  region = var.region_list[1]
}
provider "azurerm" {
  alias  = "region2"
  region = var.region_list[2]
}


# ──────────────────────────────────────────────────────────────────────────────
# 2) Module for Region 0 (Primary)
# ──────────────────────────────────────────────────────────────────────────────
module "crdb-region-0" {
  count               = local.region_count > 0 ? 1 : 0
  source              = "../terraform-azure-app"
  enable_private_dns  = var.enable_private_dns
  providers = {
    azurerm = azurerm.region0
  }

  owner               = var.owner
  project_name        = var.project_name

  # CockroachDB cluster inputs
  crdb_cluster_id           = cockroach_cluster.advanced.id
  crdb_cluster_cert         = data.cockroach_cluster_cert.cluster.cert
  crdb_private_endpoint_dns = local.crdb_private_endpoint_dns_list[0]
  crdb_public_endpoint_dns  = local.crdb_public_endpoint_dns_list[0]
  crdb_service_name         = var.crdb_service_name
  crdb_version              = var.crdb_version
  folder_path               = var.folder_path
  run_ansible               = var.run_ansible
  delete_protection         = var.delete_protection

  # AWS & Networking
  region       = var.region_list[0]
  cidr             = var.vpc_cidr_list[0]
  netskope_ips     = var.netskope_ips

  # EC2 / Application Node
  include_app        = var.include_app
  app_instance_type  = var.app_instance_type
  instance_key_name  = var.instance_keys[0]
  ssh_private_key    = var.ssh_private_key_list[0]
  my_ip_address      = var.my_ip_address

  # Resource Sizing
  node_count         = var.node_count
  storage_gib        = var.storage_gib
  num_virtual_cpus   = var.num_virtual_cpus

  # SQL User
  sql_user_name      = var.sql_user_name
  sql_user_password  = var.sql_user_password

  # Ansible / Inventory Overrides
  playbook_working_directory         = "../../ansible"
  instances_inventory_file           = "../../terraform-azure-app/inventory-${var.region_list[0]}"
  playbook_instances_inventory_file  = "../terraform-azure-app/inventory-${var.region_list[0]}"
  instances_inventory_directory      = "temp"
  inventory_template_file            = "templates/inventory.tpl"
}

# ──────────────────────────────────────────────────────────────────────────────
# 3) Module for Region 1 (Secondary)
# ──────────────────────────────────────────────────────────────────────────────
module "crdb-region-1" {
  count               = local.region_count > 1 ? 1 : 0
  source              = "../terraform-azure-app"
  enable_private_dns  = var.enable_private_dns
  providers = {
    azurerm = azurerm.region1
  }

  owner               = var.owner
  project_name        = var.project_name

  crdb_cluster_id           = cockroach_cluster.advanced.id
  crdb_cluster_cert         = data.cockroach_cluster_cert.cluster.cert
  crdb_private_endpoint_dns = local.crdb_private_endpoint_dns_list[1]
  crdb_public_endpoint_dns  = local.crdb_public_endpoint_dns_list[1]
  crdb_service_name         = var.crdb_service_name
  crdb_version              = var.crdb_version
  folder_path               = var.folder_path
  run_ansible               = var.run_ansible
  delete_protection         = var.delete_protection

  region       = var.region_list[1]
  cidr             = var.vpc_cidr_list[1]
  netskope_ips     = var.netskope_ips

  include_app        = var.include_app
  app_instance_type  = var.app_instance_type
  instance_key_name  = var.instance_keys[1]
  ssh_private_key    = var.ssh_private_key_list[1]
  my_ip_address      = var.my_ip_address

  node_count         = var.node_count
  storage_gib        = var.storage_gib
  num_virtual_cpus   = var.num_virtual_cpus

  sql_user_name      = var.sql_user_name
  sql_user_password  = var.sql_user_password

  playbook_working_directory         = "../../ansible"
  instances_inventory_file           = "../../terraform-azure-app/inventory-${var.region_list[1]}"
  playbook_instances_inventory_file  = "../terraform-azure-app/inventory-${var.region_list[1]}"
  instances_inventory_directory      = "temp"
  inventory_template_file            = "templates/inventory.tpl"
}

# ──────────────────────────────────────────────────────────────────────────────
# 4) Module for Region 2 (Tertiary)
# ──────────────────────────────────────────────────────────────────────────────
module "crdb-region-2" {
  count               = local.region_count > 2 ? 1 : 0
  source              = "../terraform-azure-app"
  enable_private_dns  = var.enable_private_dns
  providers = {
    azurerm = azurerm.region2
  }

  owner               = var.owner
  project_name        = var.project_name

  crdb_cluster_id           = cockroach_cluster.advanced.id
  crdb_cluster_cert         = data.cockroach_cluster_cert.cluster.cert
  crdb_private_endpoint_dns = local.crdb_private_endpoint_dns_list[2]
  crdb_public_endpoint_dns  = local.crdb_public_endpoint_dns_list[2]
  crdb_service_name         = var.crdb_service_name
  crdb_version              = var.crdb_version
  folder_path               = var.folder_path
  run_ansible               = var.run_ansible
  delete_protection         = var.delete_protection

  region       = var.region_list[2]
  cidr             = var.vpc_cidr_list[2]
  netskope_ips     = var.netskope_ips

  include_app        = var.include_app
  app_instance_type  = var.app_instance_type
  instance_key_name  = var.instance_keys[2]
  ssh_private_key    = var.ssh_private_key_list[2]
  my_ip_address      = var.my_ip_address

  node_count         = var.node_count
  storage_gib        = var.storage_gib
  num_virtual_cpus   = var.num_virtual_cpus

  sql_user_name      = var.sql_user_name
  sql_user_password  = var.sql_user_password

  playbook_working_directory         = "../../ansible"
  instances_inventory_file           = "../../terraform-azure-app/inventory-${var.region_list[2]}"
  playbook_instances_inventory_file  = "../terraform-azure-app/inventory-${var.region_list[2]}"
  instances_inventory_directory      = "temp"
  inventory_template_file            = "templates/inventory.tpl"
}
