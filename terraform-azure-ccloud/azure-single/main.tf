# terraform-azure-ccloud/azure-single/main.tf
module "my_azure" {
  source            = "../"
  owner             = "jphaugla"
  project_name      = "crdb"
  region_list       = ["centralus"]
  crdb_service_name = "jphaugla-api"
  #   crdb_service_name    = "jhaugland-byoc"
  node_count             = 3
  storage_gib            = 32
  folder_path            = "Jphaugla"
  num_virtual_cpus       = 4
  delete_protection      = false
  sql_user_name          = "jhaugland"
  sql_user_password      = "jasonrocks123456789"
  my_ip_address          = "12.149.152.160"
  netskope_ips           = ["8.36.116.0/24", "8.39.144.0/24", "31.186.239.0/24", "163.116.128.0/17", "162.10.0.0/17"]
  cockroach_api_token    = var.cockroach_api_token
  cockroach_server       = var.cockroach_server
  use_trusted_owners     = true
  byoc_enabled           = false
  enable_private_dns     = true
  run_ansible            = true
  subscription_id        = var.subscription_id
  tenant_id              = var.tenant_id
  vpc_cidr_list          = ["192.168.5.0/24"]
  ssh_private_key        = "~/.ssh/jhaugland-centralus.pem"
  ssh_key_resource_group = "jhaugland-key-central-us"
  ssh_key_name           = "jhaugland-centralus"
  crdb_version           = "25.3.4"
  app_vm_size            = "Standard_B8ms"
  # kafka
  include_kafka       = "no"
  kafka_instance_type = "Standard_B8ms"
}

