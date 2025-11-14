# variables.tf

variable "folder_path" {
  description = "Absolute path to the Cockroach Cloud folder (e.g. \"/prod/team1\")"
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider for the cluster"
  type        = string
  default     = "AZURE"
}

variable "plan" {
  description = "Cluster plan: BASIC, STANDARD, or ADVANCED"
  type        = string
  default     = "ADVANCED"
  validation {
    condition     = contains(["BASIC", "STANDARD", "ADVANCED"], var.plan)
    error_message = "Invalid plan: must be one of \"BASIC\", \"STANDARD\", or \"ADVANCED\"."
  }
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
 
variable "vpc_cidr_list" {
  description = "A list of IP CIDR ranges to allow as clients." 
  type        = list(string)
} 

variable "netskope_ips" {
  description = "A list of IP CIDR ranges to allow as clients. The IPs listed below are Netskope IP Ranges"
  type        = list(string)
  default     = [
    "8.36.116.0/24",
    "8.39.144.0/24",
    "31.186.239.0/24",
    "163.116.128.0/17",
    "162.10.0.0/17",
  ]
}

variable "my_ip_address" {
  description = "Your single client IP address to allow"
  type        = string
  default     = "174.141.204.193"
}

variable "ssh_key_resource_group" {
  description = "The name of the resource group containing the existing SSH Key"
  type        = string
}

variable "ssh_private_key" {
  description = "The full path of the private key"
  type        = string
}

variable "ssh_key_name" {
  description = "The name of the private key"
  type        = string
}

variable "sql_user_name" {
  description = "SQL user name"
  type        = string
}

variable "sql_user_password" {
  description = "SQL user password"
  type        = string
}
# ─────────────────────────────────────────────────────────────────────────────
# 1. MULTI-REGION DRIVER PARAMETERS
# ─────────────────────────────────────────────────────────────────────────────

variable "region_list" {
  description = "List of three AWS regions to deploy CockroachDB (e.g. [\"us-east-1\",\"us-west-2\",\"us-east-2\"])."
  type        = list(string)
  default     = ["us-east-1", "us-west-2", "us-east-2"]
}
variable "node_count" {
   description = "the number of nodes"
   type        = number
}

variable "crdb_service_name" {
   description = "the cockroachdb cloud service name"
   type        = string
}
    variable "owner" {
      description = "Owner of the infrastructure"
      type        = string
    }

    variable "project_name" {
      description = "project name to append to the owner"
      type        = string
    }

    # Optional tags
    variable "resource_tags" {
      description = "Tags to set for all resources"
      type        = map(string)
      default     = {}
    }

variable "cockroach_api_token" {
  description = "Cockroach Cloud API token (picks up from TF_VAR_cockroach_api_token)"
  type        = string
}
variable "cockroach_server" {
  description = "Cockroach Cloud API server for the URL(picks up from TF_VAR_cockroach_server)"
  type        = string
}

variable "subscription_id" {
  description = "Azure Cloud subscription ID(picks up from TF_VAR_subscription_id) only needed for byoc"
  type        = string
}

variable "tenant_id" {
  description = "Azure Cloud tenant ID(picks up from TF_VAR_tenant_id) only needed for byoc"
  type        = string
}

variable "use_trusted_owners" {
  description = "use trusted owners on this cockroachdb account"
  type        = bool
  default     = false
}

variable "enable_private_dns" {
  description = "Whether to turn on PrivateLink Private DNS"
  type        = bool
  default     = false
}
# when importing, you must also supply the per-region endpoints
variable "existing_crdb_private_endpoint_dns_list" {
  description = "Per-region INTERNAL DNS names (one per region) when create_cluster = false"
  type        = list(string)
  default     = []
}

variable "existing_crdb_public_endpoint_dns_list" {
  description = "Per-region PUBLIC SQL DNS names (one per region) when create_cluster = false"
  type        = list(string)
  default     = []
}

variable "byoc_enabled" {
  description = "Enable BYOC; include a customer_cloud_account.aws block"
  type        = bool
  default     = false
}

variable "app_vm_size" {
  description = "The Azure instance type for the crdb instances app Instance"
  type        = string
}

variable "include_kafka" {
  description = "'yes' or 'no' to include a Kafka instance"
  type        = string
  default     = "yes"
  validation {
    condition = contains(["yes", "no"], var.include_kafka)
    error_message = "Valid value for variable 'include_kafka' is : 'yes' or 'no'"
  }
}

variable "kafka_instance_type" {
  description = "The Azure instance type for the crdb instances Kafka"
  type        = string
  default     = "t3a.small"
}
 # When create_cluster = false, this must be set to the ID of your existing cluster
variable "existing_crdb_cluster_id" {
  description = "ID of an already‐provisioned CockroachDB Cloud cluster to manage."
  type        = string
  default     = ""
}

variable "create_cluster" {
  description = "If false, Terraform will not create a CockroachDB Cloud cluster but will import an existing one."
  type        = bool
  default     = true
}
variable "crdb_cluster_cert" {
  description = "PEM-encoded cluster CA cert (used when create_cluster = false)"
  type        = string
  default     = ""
}

variable "run_ansible" {
   description = "run the ansible"
   type        = bool
   default     = true
}
variable "crdb_version" {
  description = "CockroachDB Version"
  type        = string
  default     = "25.3.2"
}
