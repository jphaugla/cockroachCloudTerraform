// terraform-azure-ccloud/app-only/main.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.5.0"
    }
  }
}

# ← Manually pasted, after Phase 1:
# Fetch the cluster outputs you exported from cluster-only:
data "terraform_remote_state" "cluster" {
  backend = "local"    # or "azurerm", etc. to match your cluster-backend
  config = {
    path = "../../terraform-azure-ccloud/cluster-only/terraform.tfstate"
  }
}

module "app_nodes" {
  source                           = "../"

  ssh_private_key             = "~/.ssh/jhaugland-eastus2.pem"
  ssh_key_resource_group = "jhaugland-rg"
  ssh_key_name                    = "jhaugland-eastus2"
  virtual_network_cidr                    = "192.168.3.0/24"
  app_vm_size                    = "Standard_b8ms"
  haproxy_vm_size                = "Standard_b8ms"
  app_disk_size                    = 128
  my_ip_address                    = "67.220.19.36"
  netskope_ips                     = ["8.36.116.0/24", "8.39.144.0/24", "31.186.239.0/24", "163.116.128.0/17", "162.10.0.0/17", "69.120.106.187"]
  crdb_version = "25.3.0"

  # CRDB info from Phase 1
  crdb_cluster_id                  = data.terraform_remote_state.cluster.outputs.crdb_cluster_id
  crdb_public_endpoint_dns         = data.terraform_remote_state.cluster.outputs.crdb_public_endpoint_dns
  crdb_cluster_cert                = data.terraform_remote_state.cluster.outputs.crdb_cluster_cert
  sql_user_name                    = data.terraform_remote_state.cluster.outputs.sql_user_name
  sql_user_password                = data.terraform_remote_state.cluster.outputs.sql_user_password
  virtual_network_location         = data.terraform_remote_state.cluster.outputs.region
  owner                            = data.terraform_remote_state.cluster.outputs.owner
  resource_name                    =  data.terraform_remote_state.cluster.outputs.project_name


# Ansible / Inventory
  playbook_working_directory         = "../../ansible"
  instances_inventory_file           = "../../terraform-azure-app/inventory-${data.terraform_remote_state.cluster.outputs.region}"
  playbook_instances_inventory_file  = "../terraform-azure-app/inventory-${data.terraform_remote_state.cluster.outputs.region}"
  instances_inventory_directory      = "temp"
  inventory_template_file            = "templates/inventory.tpl"
  ansible_verbosity_switch           =  "-v"
  # kafka
  include_kafka = "yes"
  kafka_instance_type = "Standard_b8ms"
  cockroach_api_token = var.cockroach_api_token
  crdb_private_endpoint_dns = "internal-jphaugla-crdb-adv-nqh.azure-eastus2.cockroachlabs.cloud"
  run_ansible          = true
}

