# terraform.tfvars.example
module "my_azure" {
source               = "../"
enable_private_dns = false
# the owner and cluster_postfix will be joined to make the cluster name
owner                = "jphaugla"
project_name         = "crdb"
region_list      = ["eastus2"]
ssh_private_key_list = [
    "~/.ssh/jhaugland-eastus2.pem"
]
instance_keys = [
    "jhaugland-eastus2"
]
vpc_cidr_list = [
    "192.168.3.0/24"
]
app_instance_type    = "Standard_b4ms"
app_disk_size        = 128
crdb_service_name    = "jphaugla-api"
run_ansible          = true
node_count           = 3
storage_gib          = 32
folder_path          = "/Jphaugla"
num_virtual_cpus     = 4
delete_protection    = false
sql_user_name 	     = "jhaugland"
sql_user_password    = "jasonrocks123456789"
my_ip_address        = "174.141.204.193"
# ----------------------------------------
# The following was created to account for NetSkope Tunneling
# ----------------------------------------
netskope_ips = ["8.36.116.0/24" ,"8.39.144.0/24", "31.186.239.0/24", "163.116.128.0/17", "162.10.0.0/17"]
crdb_version = "25.2.1"
}
