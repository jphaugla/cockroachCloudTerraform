# terraform.tfvars.example
module "my_aws" {

enable_private_dns = true

# the owner and cluster_postfix will be joined to make the cluster name
owner                = "jphaugla"
project_name         = "crdb"
aws_region_list      = ["us-east-1", "us-west-2", "us-east-2"]
ssh_private_key_list = [
    "~/.ssh/jph-cockroach-us-east-1-kp01.pem",
    "~/.ssh/jph-cockroach-us-west-2-kp01.pem",
    "~/.ssh/jph-cockroach-us-east-2-kp01.pem"
]
aws_instance_keys = [
    "jph-cockroach-us-east-1-kp01",
    "jph-cockroach-us-west-2-kp01",
    "jph-cockroach-us-east-2-kp01"
]
vpc_cidr_list = [
    "192.168.3.0/24",
    "192.168.4.0/24",
    "192.168.5.0/24"
]
aws_config           = ["/Users/jasonhaugland/.aws2/config"]
app_instance_type    = "t3.xlarge"
aws_credentials      = ["/Users/jasonhaugland/.aws2/credentials"]
crdb_service_name    = "jphaugla-api"
run_ansible          = true
node_count           = 3
storage_gib          = 20
folder_path          = "/Jphaugla"
num_virtual_cpus     = 4
delete_protection    = false
source               = "../"
sql_user_name 	     = "jhaugland"
sql_user_password    = "jasonrocks123456789"
my_ip_address        = "174.141.204.193"
# ----------------------------------------
# The following was created to account for NetSkope Tunneling
# ----------------------------------------
netskope_ips = ["8.36.116.0/24" ,"8.39.144.0/24", "31.186.239.0/24", "163.116.128.0/17", "162.10.0.0/17"]
crdb_version = "25.2.3"
cockroach_api_token = var.cockroach_api_token
}
