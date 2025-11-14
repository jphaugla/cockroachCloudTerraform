# terraform-azure-ccloud/cluster.tf
# ----------------------------------------------------------------------
# Conditional creation of CockroachDB Cloud cluster (controlled by var.create_cluster)
# ----------------------------------------------------------------------

# Look up the folder only when creating the cluster
data "cockroach_folder" "target" {
  count = var.create_cluster ? 1 : 0
  path  = var.folder_path
}

# Create the CockroachDB Cloud cluster
resource "cockroach_cluster" "advanced" {
  count          = var.create_cluster ? 1 : 0
  name           = local.cluster_name
  parent_id      = data.cockroach_folder.target[0].id
  cloud_provider = var.cloud_provider         # "AZURE"
  plan           = var.plan                   # "ADVANCED"

  dedicated = {
    storage_gib      = var.storage_gib
    num_virtual_cpus = var.num_virtual_cpus
  }

  regions           = local.effective_regions
  delete_protection = var.delete_protection

  # BYOC (Bring Your Own Cloud) configuration for Azure
  customer_cloud_account = var.byoc_enabled ? {
    azure = {
      subscription_id = var.subscription_id
      tenant_id       = var.tenant_id
    }
  } : null
}

# ----------------------------------------------------------------------
# Allow-list: Netskope CIDRs (only when cluster is created)
# ----------------------------------------------------------------------
resource "cockroach_allow_list" "netskope" {
  for_each = var.create_cluster ? {
    for cidr in var.netskope_ips :
    cidr => {
      ip   = element(split("/", cidr), 0)
      mask = tonumber(element(split("/", cidr), 1))
    }
  } : {}

  cluster_id = cockroach_cluster.advanced[0].id
  cidr_ip    = each.value.ip
  cidr_mask  = each.value.mask
  ui         = true
  sql        = true
}

# ----------------------------------------------------------------------
# Allow-list: Your IP (/32)
# ----------------------------------------------------------------------
resource "cockroach_allow_list" "my_ip" {
  count      = var.create_cluster ? 1 : 0
  cluster_id = cockroach_cluster.advanced[0].id
  cidr_ip    = var.my_ip_address
  cidr_mask  = 32
  ui         = true
  sql        = true
}

# ----------------------------------------------------------------------
# SQL User (only when creating)
# ----------------------------------------------------------------------
# resource "cockroach_sql_user" "app_user" {
#   count      = var.create_cluster ? 1 : 0
#   cluster_id = cockroach_cluster.advanced[0].id
#   name       = var.sql_user_name
#   password   = var.sql_user_password
# }

# ----------------------------------------------------------------------
# Cluster certificate (use existing if not creating)
# ----------------------------------------------------------------------
data "cockroach_cluster_cert" "cluster" {
  count = var.create_cluster ? 1 : 0
  id    = local.cluster_id
}

# ----------------------------------------------------------------------
# Unified local outputs
# ----------------------------------------------------------------------
locals {
  cluster_id        = var.create_cluster ? cockroach_cluster.advanced[0].id : var.existing_crdb_cluster_id
  crdb_cluster_cert = var.create_cluster ? data.cockroach_cluster_cert.cluster[0].cert : var.crdb_cluster_cert
}

