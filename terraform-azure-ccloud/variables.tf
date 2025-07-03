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
  sensitive   = true
  default     = ""
}
