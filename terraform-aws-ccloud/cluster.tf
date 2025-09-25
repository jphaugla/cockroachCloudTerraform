# cluster.tf

# Look up the folder by path (only when creating a new cluster)
data "cockroach_folder" "target" {
  count = var.create_cluster ? 1 : 0
  path  = var.folder_path
}

# Create a new cluster ONLY when requested
resource "cockroach_cluster" "advanced" {
  count = var.create_cluster ? 1 : 0

  name           = "${var.owner}-${var.project_name}-adv-${var.cloud_provider}"
  parent_id      = data.cockroach_folder.target[0].id
  cloud_provider = var.cloud_provider    # e.g. "AWS"
  plan           = var.plan              # e.g. "ADVANCED"

  dedicated = {
    storage_gib      = var.storage_gib      # GiB per node
    num_virtual_cpus = var.num_virtual_cpus # vCPUs per node
  }

  regions           = local.effective_regions
  delete_protection = var.delete_protection
}

# Unified handles for downstream code (no provider calls when create_cluster = false)
locals {
  # Caller provides existing_crdb_cluster_id when create_cluster = false
  cluster_id = var.create_cluster ? cockroach_cluster.advanced[0].id : var.existing_crdb_cluster_id
}

# ─────────────────────────────────────────────────────────────────────────────
# OPTIONAL cockroach resources — ONLY when create_cluster = true
# ─────────────────────────────────────────────────────────────────────────────

# One allow-list entry per Netskope CIDR
resource "cockroach_allow_list" "netskope" {
  for_each = var.create_cluster ? {
    for cidr in var.netskope_ips :
    cidr => {
      ip   = element(split("/", cidr), 0)
      mask = tonumber(element(split("/", cidr), 1))
    }
  } : {}

  cluster_id = local.cluster_id
  cidr_ip    = each.value.ip
  cidr_mask  = each.value.mask
  ui         = true
  sql        = true
}

# Your single IP (/32)
resource "cockroach_allow_list" "my_ip" {
  count      = var.create_cluster ? 1 : 0
  cluster_id = local.cluster_id
  cidr_ip    = var.my_ip_address
  cidr_mask  = 32
  ui         = true
  sql        = true
}

# Create the SQL user in the new cluster
resource "cockroach_sql_user" "app_user" {
  count      = var.create_cluster ? 1 : 0
  cluster_id = local.cluster_id
  name       = var.sql_user_name
  password   = var.sql_user_password
}

# Cluster cert (optional):
#  - When creating, fetch via provider
#  - When importing, expect the caller to pass var.crdb_cluster_cert
data "cockroach_cluster_cert" "cluster" {
  count = var.create_cluster ? 1 : 0
  id    = local.cluster_id
}

locals {
  crdb_cluster_cert = var.create_cluster ? data.cockroach_cluster_cert.cluster[0].cert : var.crdb_cluster_cert
}
