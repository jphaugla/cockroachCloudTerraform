# cluster.tf
# look up the folder by path
data "cockroach_folder" "target" {
  path = var.folder_path
}     

resource "cockroach_cluster" "advanced" {
  name           = "${var.owner}-${var.project_name}-adv-aws"
  parent_id      = data.cockroach_folder.target.id   # put cluster in this folder :contentReference[oaicite:1]{index=1}
  cloud_provider = var.cloud_provider    # e.g. "AWS"
  plan           = var.plan              # "ADVANCED"
  
  dedicated = {
    storage_gib      = var.storage_gib      # GiB per node
    num_virtual_cpus = var.num_virtual_cpus # vCPUs per node
  }

  regions = local.effective_regions

  delete_protection = var.delete_protection
}

# one allow-list entry per Netskope CIDR
resource "cockroach_allow_list" "netskope" {
  for_each   = { for cidr in var.netskope_ips :
                   cidr => {
                     ip   = element(split("/", cidr), 0)
                     mask = tonumber(element(split("/", cidr), 1))
                   }
                 }

  cluster_id = cockroach_cluster.advanced.id
  cidr_ip    = each.value.ip
  cidr_mask  = each.value.mask
  ui         = true
  sql        = true
}

# your single IP (/32)
resource "cockroach_allow_list" "my_ip" {
  cluster_id = cockroach_cluster.advanced.id
  cidr_ip    = var.my_ip_address
  cidr_mask  = 32
  ui         = true
  sql        = true
}

# create the SQL user in the new cluster
resource "cockroach_sql_user" "app_user" {
  cluster_id = cockroach_cluster.advanced.id
  name       = var.sql_user_name
  password   = var.sql_user_password
}
 
# data source to grab the cluster cert for your cluster
data "cockroach_cluster_cert" "cluster" {
  # use the resource you already created
  id = cockroach_cluster.advanced.id
}
