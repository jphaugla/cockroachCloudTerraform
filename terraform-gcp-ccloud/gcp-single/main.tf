# terraform.tfvars.example
module "my_gcp" {
enable_private_dns = false
enable_privatelink = false
# the owner and cluster_postfix will be joined to make the cluster name
owner                = "jhaug"
project_id           = "cockroach-jhaugland"
gcp_account_id       = var.gcp_account_id
gcp_region_list      = ["us-east1"]
ssh_private_key_list = [ "~/.ssh/jph-cockroach-gcp" ]
gcp_credentials_file = "~/.config/gcloud/application_default_credentials.json"
vpc_cidr_list        = [ "192.168.5.0/24" ]
app_instance_type    = "e2-standard-8"
# crdb_service_name    = "jhaugland-byoc"
crdb_service_name    = "jphaugla-api"
run_ansible          = false
node_count           = 3
storage_gib          = 20
folder_path          = "Jphaugla"
num_virtual_cpus     = 4
delete_protection    = false
source               = "../"
sql_user_name 	     = "jhaugland"
sql_user_password    = "jasonrocks123456789"
my_ip_address        = "67.220.19.71"
cockroach_server     = var.cockroach_server
use_trusted_owners   = true
byoc_enabled         = false
# ----------------------------------------
# The following was created to account for NetSkope Tunneling
# ----------------------------------------
netskope_ips = ["8.36.116.0/24" ,"8.39.144.0/24", "31.186.239.0/24", "163.116.128.0/17", "162.10.0.0/17"]
crdb_version = "25.3.4"
cockroach_api_token = var.cockroach_api_token
# kafka
include_kafka = "yes"
kafka_instance_type = "e2-standard-8"
}
