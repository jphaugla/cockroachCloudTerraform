#  ----------------------------------------
# Cluster Enterprise License Keys
# ----------------------------------------
variable "install_enterprise_keys" {
  description = "Install enterprise license keys (yes/no)"
  type        = string
  default     = "no"
  validation {
 condition     = contains(["yes","no"], var.install_enterprise_keys)
 error_message = "Valid value is 'yes' or 'no'"
  }
}

# ---------------------------------------
# Cluster Location Data - For console map
# ----------------------------------------
variable "install_system_location_data" {
  description = "Install system.location data (yes/no)"
  type        = string
  default     = "yes"
  validation {
 condition     = contains(["yes","no"], var.install_system_location_data)
 error_message = "Valid value is 'yes' or 'no'"
  }
}

# ----------------------------------------
# Regions
# ----------------------------------------
variable "virtual_network_location" {
  description = "GCP region"
  type        = string
  default     = "us-east1"
}

variable "gcp_region_list" {
  description = "List of regions for multiregion demo"
  type        = list(string)
  default     = ["us-east1","us-west1","us-east4"]
}

# ----------------------------------------
# TAGS
# ----------------------------------------
variable "project_id" {
  description = "google project id get iwth gcloud config get-value project"
  type        = string
  default     = "terraform-test"
}

variable "owner" {
  description = "Owner of the infrastructure"
  type        = string
  default     = ""
}

variable "resource_tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}

# ----------------------------------------
# CIDR
# ----------------------------------------
variable "cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "192.168.4.0/24"
}

# ----------------------------------------
# My IP Address & SSH Key
# ----------------------------------------
variable "my_ip_address" {
  description = "Your public IP for SSH & DB ports"
  type        = string
  default     = "0.0.0.0"
}
# ----------------------------------------
# The following was created to account for NetSkope Tunneling
# ----------------------------------------
variable netskope_ips {
  description = "A list of IP CIDR ranges to allow as clients.  The IPs listed below are Netskope IP Ranges"
  default     = ["8.36.116.0/24" ,"8.39.144.0/24", "31.186.239.0/24", "163.116.128.0/17", "162.10.0.0/17"]
  type        = list(string)
}

variable "ssh_private_key" {
  description = "Path to SSH private key"
  type        = string
}

# ----------------------------------------
# CRDB Instance Specifications
# ----------------------------------------
variable "join_string" {
  description = "CRDB join string (auto-generated)"
  type        = string
  default     = ""
}

variable "prometheus_string" {
  description = "Prometheus string (auto-generated)"
  type        = string
  default     = ""
}

variable "prometheus_app_string" {
  description = "Prometheus app string (auto-generated)"
  type        = string
  default     = ""
}

variable "crdb_nodes" {
  description = "Number of CRDB nodes (multiple of 3)"
  type        = number
  default     = 3
  validation {
 condition     = var.crdb_nodes % 3 == 0
 error_message = "'crdb_nodes' must be a multiple of 3"
  }
}

variable "crdb_instance_type" {
  description = "Instance type for CRDB nodes"
  type        = string
  default     = "e2-standard-4"
}

variable "crdb_store_volume_type" {
  description = "Disk type for store volume"
  type        = string
  default     = "pd-standard"
}

variable "crdb_store_volume_size" {
  description = "Size (GB) for store volume"
  type        = number
  default     = 8
}

variable "crdb_version" {
  description = "CockroachDB version"
  type        = string
  default     = "25.2.0"
}

variable "crdb_arm_release" {
  description = "Use ARM release of CRDB (yes/no)"
  type        = string
  default     = "yes"
  validation {
 condition     = contains(["yes","no"], var.crdb_arm_release)
 error_message = "Valid value is 'yes' or 'no'"
  }
}

variable "crdb_enable_spot_instances" {
  description = "Use preemptible instances for CRDB (yes/no)"
  type        = string
  default     = "no"
  validation {
 condition     = contains(["yes","no"], var.crdb_enable_spot_instances)
 error_message = "Valid value is 'yes' or 'no'"
  }
}

variable "crdb_file_location" {
  description = "Mount point for CRDB data"
  type        = string
  default     = "/mnt/data"
}

variable "crdb_root_volume_type" {
  description = "Disk type for root volume"
  type        = string
  default     = "pd-standard"
}

variable "crdb_root_volume_size" {
  description = "Size (GB) for root volume"
  type        = number
  default     = 8
}

variable "run_init" {
  description = "Include HAProxy (yes/no)"
  type        = string
  default     = "yes"
}

variable "create_dbadmin_user" {
  description = "Create DB admin user (yes/no)"
  type        = string
  default     = "yes"
}

variable "dbadmin_user_name" {
  description = "DB admin username"
  type        = string
  default     = ""
}

variable "dbadmin_user_password" {
  description = "DB admin password"
  type        = string
  default     = ""
}

# ----------------------------------------
# HA Proxy Specs
# ----------------------------------------
variable "include_ha_proxy" {
  description = "Include HAProxy (yes/no)"
  type        = string
  default     = "yes"
}

variable "haproxy_instance_type" {
  description = "HAProxy instance type"
  type        = string
  default     = "e2-small"
}

# ----------------------------------------
# Kafka Specs
# ----------------------------------------
variable "include_kafka" {
  description = "Include Kafka (yes/no)"
  type        = string
  default     = "no"
}

variable "kafka_instance_type" {
  description = "Kafka instance type"
  type        = string
  default     = "e2-small"
}

# ----------------------------------------
# App Specs
# ----------------------------------------
variable "include_app" {
  description = "Include app (yes/no)"
  type        = string
  default     = "yes"
}

variable "app_instance_type" {
  description = "App instance type"
  type        = string
  default     = "e2-standard-4"
}

variable "setup_migration" {
  description = "Setup migration (yes/no)"
  type        = string
  default     = "yes"
}

# ----------------------------------------
# Demo & TLS
# ----------------------------------------
variable "include_demo" {
  description = "Include demo resources (yes/no)"
  type        = string
  default     = "yes"
}

variable "tls_private_key" {
  description = "TLS private key PEM"
  type        = string
  default     = ""
}

variable "tls_public_key" {
  description = "TLS public key PEM"
  type        = string
  default     = ""
}

variable "tls_cert" {
  description = "TLS CA cert PEM"
  type        = string
  default     = ""
}

variable "tls_user_cert" {
  description = "TLS user cert PEM"
  type        = string
  default     = ""
}

variable "tls_user_key" {
  description = "TLS user key PEM"
  type        = string
  default     = ""
}

# ----------------------------------------
# Ansible Inventory
# ----------------------------------------
variable "instances_inventory_file" {
  description = "Inventory file path for Ansible"
  type        = string
  default     = "../inventory"
}

variable "playbook_working_directory" {
  description = "Ansible working directory"
  type        = string
  default     = "../../ansible"
}

variable "playbook_instances_inventory_file" {
  description = "Inventory file for playbook"
  type        = string
  default     = "../terraform-gcp/inventory"
}

variable "instances_inventory_directory" {
  description = "Directory for inventory files"
  type        = string
  default     = "../temp/"
}

variable "inventory_template_file" {
  description = "Path to inventory.tpl"
  type        = string
  default     = "../terraform-gcp/templates/inventory.tpl"
}

variable "include_load_balancer" {
  description = "Include load balancer (yes/no)"
  type        = string
  default     = "yes"
}

variable "ansible_verbosity_switch" {
  description = "Verbosity flag for Ansible"
  type        = string
  default     = ""
}


variable "allow_non_tls" {
  description = "start the nodes with the accept-sql-without-tls flag which is insecure"
  type        = bool
  default     = false
}
variable "run_ansible" {
  type        = bool
  description = "Whether to run the Ansible playbooks in each region"
  default     = true
}

variable "gcp_credentials_file" {
  description = "Path to your Google Cloud ADC JSON file"
  type        = string
}

variable "do_crdb_init" {
  type        = bool
  description = "run the crdb_init.  this is mainly for multi-region to only run in one region"
  default     = true
}

variable "do_network_create" {
  type        = bool
  description = "create the network if true, otherwise import the network in multi-region"
  default     = true
}

#  variables for cloud
variable "folder_path" {
  description = "Absolute path to the Cockroach Cloud folder (e.g. \"/prod/team1\")"
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider for the cluster"
  type        = string
  default     = "AWS"
}

variable "cockroach_server" {
  description = "Cockroach Cloud API server for the URL"
  type        = string
  default     = "https://cockroachlabs.cloud"
}

variable "plan" {
  description = "Cluster plan: BASIC, STANDARD, or ADVANCED"
  type        = string
  default     = "ADVANCED"
}

variable "regions" {
  description = "Optional list of regions + node counts. If empty, we'll use aws_region/node_count."
  type        = list(object({ name = string, node_count = number }))
  default     = []
}

variable "storage_gib" {
  description = "Storage (GiB) per node"
  type        = number
  default     = 15
}

variable "num_virtual_cpus" {
  description = "Number of vCPUs per node"
  type        = number
  default     = 4
}

variable "delete_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
  default     = true
}
variable "sql_user_name" {
  description = "SQL user name"
  type        = string
}

variable "sql_user_password" {
  description = "SQL user password"
  type        = string
}

variable "enable_private_dns" {
  description = "Whether to turn on AWS PrivateLink Private DNS"
  type        = bool
  default     = false
}

variable "enable_privatelink" {
  description = "Whether to enable privatelink"
  type        = bool
  default     = true
}

variable "use_trusted_owners" {
  description = "use trusted owners on this cockroachdb account"
  type        = bool
  default     = false
}

variable "cockroach_api_token" {
  description = "Cockroach Cloud API token (picks up from TF_VAR_cockroach_api_token)"
  type        = string
}

variable "crdb_private_endpoint_dns" {
  description = "private endpoint for cockroach cloud"
  type        = string
}

variable "crdb_public_endpoint_dns" {
  description = "public endpoint for cockroach cloud"
  type        = string
}

variable "crdb_cluster_id" {
  description = "The ID of the CockroachDB cluster to connect/apply allow-lists against"
  type        = string
}

variable "crdb_cluster_cert" {
  description = "PEM-encoded CA certificate for the CockroachDB cluster"
  type        = string
}
variable "node_count" {
   description = "the number of nodes"
   type        = number
}

variable "crdb_service_name" {
   description = "the cockroachdb cloud service name"
   type        = string
}

variable "allow_psc_global_access" {
  description = "Allow Private Service Connect endpoint to be accessed from any region."
  type        = bool
  default     = false
}
variable "psc_producer_project_id" {
  description = "GCP project that hosts the CockroachDB service attachment use getClusters to get the account id"
  type        = string
  default     = ""
}
