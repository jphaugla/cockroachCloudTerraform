# locals.tf
locals {
  # Build one entry per region-string, each with the same node_count
  effective_regions = [
    for r in var.region_list : {
      name       = r
      node_count = var.node_count
    }
  ]
  required_tags = {
    owner   = var.owner
    project = var.project_name
  }

  tags           = merge(var.resource_tags, local.required_tags)
  admin_username = "adminuser"

  crdb_private_endpoint_dns_list = var.create_cluster ?  [for r in cockroach_cluster.advanced[0].regions : r.private_endpoint_dns] : var.existing_crdb_private_endpoint_dns_list
  crdb_public_endpoint_dns_list = var.create_cluster ?  [for r in cockroach_cluster.advanced[0].regions : r.sql_dns] : var.existing_crdb_public_endpoint_dns_list
  region_count = length(local.crdb_private_endpoint_dns_list)
  cluster_name = "${var.owner}-${var.project_name}-adv-azure"
}

