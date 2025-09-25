// terraform-azure-app/azure-existing/main.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.5.0"
    }
  }
}

# ← Manually pasted, after Phase 1:
module "app_nodes" {
  source                           = "../"
  ssh_private_key                  = "~/.ssh/jhaugland-byoc-centralus.pem"
  ssh_key_resource_group           = "jhaugland-rg"
  ssh_key_name                     = "jhaugland-byoc-centralus"
  virtual_network_cidr             = "192.168.3.0/24"
  app_vm_size                      = "Standard_b8ms"
  haproxy_vm_size                  = "Standard_b8ms"
  app_disk_size                    = 128
  my_ip_address                    = "67.220.19.71"
  netskope_ips                     = ["8.36.116.0/24", "8.39.144.0/24", "31.186.239.0/24", "163.116.128.0/17", "162.10.0.0/17", "69.120.106.187"]
  crdb_version                     = "25.3.1"

  # CRDB info from Phase 1
  crdb_cluster_id                  = var.cluster_id
  crdb_public_endpoint_dns         = "byoc-jph-azure-1-9wt8.azure-centralus.crdb.io"
  crdb_cluster_cert                = <<EOF
-----BEGIN CERTIFICATE-----
MIIDnzCCAoegAwIBAgIUeDaraljp7lcuX157uLgBfw4NbIAwDQYJKoZIhvcNAQEL
BQAwSDErMCkGA1UEChMiQ29ja3JvYWNoIExhYnMgY3JsLXN0YWdpbmctOXd0OCBD
QTEZMBcGA1UEAxMQY3JsLXN0YWdpbmctOXd0ODAeFw0yNTA5MTkyMjI3NTBaFw0z
NTA5MTcyMjI4MjBaMEgxKzApBgNVBAoTIkNvY2tyb2FjaCBMYWJzIGNybC1zdGFn
aW5nLTl3dDggQ0ExGTAXBgNVBAMTEGNybC1zdGFnaW5nLTl3dDgwggEiMA0GCSqG
SIb3DQEBAQUAA4IBDwAwggEKAoIBAQDu4FPypcyyhm8JtAX6j6kN+XYg+bjLwOdn
EGpbqO2ZsRfS/g2azPu3A/BPnh0FTTPPZ80k5mN7qtU05C0F6CiCFPq23YALroCB
bAOi529wAFPezke1iu81nlHmBcqd+bqnXQeFI5Xc3ULjlIFnbhPCOque9CLs2uxu
VIoASDZGJlpJ2lH+z94oGSJ20+gRgVWCQLabFcSqBjitaG+YW593nI5IDBjomORL
Xn59wWiHvcdw9NqE4FbumKEDQBnQ11SBgPu3T+22SGW0SnmHiWIHJJsRVVNfwdkc
h1zVKT4SWw6/VtEbC2iaE7Lp+qLPcdnZ0/5ZRf43/Gd/pqphgJZpAgMBAAGjgYAw
fjAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUaAPw
/XXGPe7CM1BsemMdfeOAIeQwHwYDVR0jBBgwFoAUaAPw/XXGPe7CM1BsemMdfeOA
IeQwGwYDVR0RBBQwEoIQY3JsLXN0YWdpbmctOXd0ODANBgkqhkiG9w0BAQsFAAOC
AQEAoQVvkXegTG97jSF99pzyB0lWD+gvCT7EfV3j4DY8iPNgcHSxj8g7PBptAdK2
JfgYr3RjteW+/V4+HfojoQs9LPuC2+0/2wX9Y5Qi8PwwbeppBGeA6W8xf4qvtY5s
foGkbgPPoIzwknz1irfkhJxLOr08/ryLQ9gS5ZZI+54PpT9syhjAMYY24lQf3vKi
sjwxkU3hkqaJni/auuNbqmfpjOIGdvEswLzVxDXUeLLt3RFZyHIFqs4rvHp8G8Vg
wYKbm6jSNgi8nmWfQj5wAcuTEeVZq5ZiCgJaQR128uji4oCv04TlqlC/A1v0dXR4
Xd1eIxpyknMIX/X4wvOysH5+AQ==
-----END CERTIFICATE-----
EOF
  sql_user_name        = "jhaugland"
  sql_user_password    = "jasonrocks123456789"
  virtual_network_location         = "centralus"
  owner                            = "jphaugla"
  resource_name                    = "crdb"

# Ansible / Inventory
  playbook_working_directory         = "../../ansible"
  instances_inventory_file           = "../../terraform-azure-app/inventory-centralus"
  playbook_instances_inventory_file  = "../terraform-azure-app/inventory-centralus"
  instances_inventory_directory      = "temp"
  inventory_template_file            = "templates/inventory.tpl"
  ansible_verbosity_switch           =  "-v"
  # kafka
  include_kafka                      = "no"
  kafka_instance_type                = "Standard_b8ms"
  cockroach_api_token                = var.cockroach_api_token
  crdb_private_endpoint_dns          = "internal-byoc-jph-azure-1-9wt8.azure-centralus.crdb.io"
  run_ansible                        = true
  deploy_azure_sql                   = false
  enable_private_dns                 = true
  deploy_event_hub                   = false
  crdb_cloud_url	             = "management-staging.crdb.io"
}

