module "my_azure" {
  source               = "../"
  owner                = "jphaugla"
  project_name         = "crdb"
  region_list          = ["eastus2"]
  crdb_service_name    = "jphaugla-api"
  node_count           = 3
  storage_gib          = 32
  folder_path          = "/Jphaugla"
  num_virtual_cpus     = 4
  delete_protection    = false
  sql_user_name        = "jhaugland"
  sql_user_password    = "jasonrocks123456789"
  my_ip_address        = "67.220.19.36"
  netskope_ips         = ["8.36.116.0/24", "8.39.144.0/24", "31.186.239.0/24", "163.116.128.0/17", "162.10.0.0/17"]
  cockroach_api_token  = var.cockroach_api_token
}
