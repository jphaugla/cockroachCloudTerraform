# terraform.tfvars.example
module "my_aws" {

enable_private_dns = true

# the owner and cluster_postfix will be joined to make the cluster name
owner                = "jphaugla"
project_name         = "crdb"
aws_region_list      = ["us-east-2"]
ssh_private_key_list = [ "~/.ssh/jph-cockroach-stage-us-east-2.pem" ]
aws_instance_keys    = [ "jph-cockroach-stage-us-east-2" ]
vpc_cidr_list        = [ "192.168.5.0/24" ]
app_instance_type    = "t3.xlarge"
crdb_service_name    = "jhaugland-byoc"
existing_crdb_cluster_id = var.cluster_id
existing_crdb_public_endpoint_dns_list  = ["byoc-jph-1-9rwb.aws-us-east-2.crdb.io"]
existing_crdb_private_endpoint_dns_list = ["internal-byoc-jph-1-9rwb.aws-us-east-2.crdb.io"]
crdb_cluster_cert = <<EOF
-----BEGIN CERTIFICATE-----
MIIDnzCCAoegAwIBAgIUDtf1scgJKRPxVyRfQRB9Tyb/cBkwDQYJKoZIhvcNAQEL
BQAwSDErMCkGA1UEChMiQ29ja3JvYWNoIExhYnMgY3JsLXN0YWdpbmctOXJ3YiBD
QTEZMBcGA1UEAxMQY3JsLXN0YWdpbmctOXJ3YjAeFw0yNTA4MTEyMTExMjZaFw0z
NTA4MDkyMTExNTZaMEgxKzApBgNVBAoTIkNvY2tyb2FjaCBMYWJzIGNybC1zdGFn
aW5nLTlyd2IgQ0ExGTAXBgNVBAMTEGNybC1zdGFnaW5nLTlyd2IwggEiMA0GCSqG
SIb3DQEBAQUAA4IBDwAwggEKAoIBAQDVxBb5NzGOqleafKzL5E9F/rP4tPK2qIhV
pmynl55NSwTv9ukl/dkROXiY/rxs08IS0tCeu1C8YLCQ1ybI+X/+1HS3L9RDhs9f
G/3C6vxfC3vrgRoBP39xnwvfVHCzX1N9qBTZsSWwAbk93Scqw3DJZwa5GFkye18t
8r7qKFE3Fn3/DfjEuFNfGoD9vw9Q5l5VymAkAYWF/CU4PEI81Aw/12Rj4eIr4c/B
abblXNS2Qiu5J55JkG0zxTg8v5D+hNQj4RWsbBCbV2j5VH6ghigS4uWY2nU8xOmm
hduIP+7dCY3XY8OrTKwFQKny2dWr5xEzM/ZlxI/OT8njSWXA04zfAgMBAAGjgYAw
fjAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUYeWZ
iqunEuqGJ1p4dTsi3S13tlowHwYDVR0jBBgwFoAUYeWZiqunEuqGJ1p4dTsi3S13
tlowGwYDVR0RBBQwEoIQY3JsLXN0YWdpbmctOXJ3YjANBgkqhkiG9w0BAQsFAAOC
AQEAnL4hcK0WmfwZ4rNPn9usrGxuFW4A6p0DFeC2/9dFwnhS/osLk5SMdpCf4YfC
kmR0KcMsekC55XvAh9fIh1EsgVruy6jFKUt7UPXb7/dejos5YdBBfDmTQ5+ghTL4
g3v+YbNkG9C63qXC6dbghTxK3CUSd1i/mOEFpC7tegAh9uL+qygrntFnoCnRNkAc
6HMTm0HB8Iywj4WYg0u2Fl2AU517HojyGHBCs/7i8zQA1LboDTXzk7VI606AmUg/
D6783gZQWlkJGwQQhj9qDd8A/WyPLTcX/YvL52vRGk7yMwy7Xg5MsKeGiutgS7Bs
azR1nJsB8ISoV6Sf6TxuxIRuDA==
-----END CERTIFICATE-----
EOF
run_ansible          = true
enable_privatelink   = false
folder_path          = ""
create_cluster       = false
source               = "../"
sql_user_name 	     = "jhaugland"
sql_user_password    = "jasonrocks123456789"
cockroach_server     = var.cockroach_server
my_ip_address        = "67.220.19.36"
# ----------------------------------------
# The following was created to account for NetSkope Tunneling
# ----------------------------------------
netskope_ips = ["8.36.116.0/24" ,"8.39.144.0/24", "31.186.239.0/24", "163.116.128.0/17", "162.10.0.0/17"]
crdb_version = "25.2.4"
cockroach_api_token = var.cockroach_api_token
# kafka
include_kafka = "yes"
kafka_instance_type = "t3a.xlarge"
}
