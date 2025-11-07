# variables.tf

variable "folder_path" {
  description = "Absolute path to the Cockroach Cloud folder (e.g. \"/prod/team1\")"
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider for the cluster"
  type        = string
  default     = "GCP"
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

variable "gcp_region_list" {
  description = "List of three GCP regions to deploy CockroachDB (e.g. [\"us-east-1\",\"us-west-2\",\"us-east-2\"])."
  type        = list(string)
  default     = ["us-east-1", "us-west-2", "us-east-2"]
}

variable "gcp_instance_keys" {
  description = "List of three EC2 Key Pair names—one per region, in the same order as gcp_region_list."
  type        = list(string)
  default     = [
    "nollen-cockroach-us-east-1-kp01",
    "nollen-cockroach-us-west-2-kp01",
    "nollen-cockroach-us-east-2-kp01"
  ]
}

variable "ssh_private_key_list" {
  description = "List of three local paths to the private key files—one per region, matching gcp_instance_keys."
  type        = list(string)
  default     = [
    "~/.ssh/nollen-cockroach-us-east-1-kp01.pem",
    "~/.ssh/nollen-cockroach-us-west-2-kp01.pem",
    "~/.ssh/nollen-cockroach-us-east-2-kp01.pem"
  ]
}

variable "vpc_cidr_list" {
  description = "List of three VPC CIDR blocks—one per region."
  type        = list(string)
  default     = ["192.168.3.0/24", "192.168.4.0/24", "192.168.5.0/24"]
}

variable "run_ansible" {
   description = "run the ansible"
   type        = bool
   default     = true
}

variable "node_count" {
   description = "the number of nodes"
   type        = number
   default     = 3
}

variable "crdb_service_name" {
   description = "the cockroachdb cloud service name"
   type        = string
}
# ----------------------------------------
# ----------------------------------------
# APP Instance Specifications
# ----------------------------------------
    variable "include_app" {
      description = "'yes' or 'no' to include an HAProxy Instance"
      type        = string
      default     = "yes"
      validation {
        condition = contains(["yes", "no"], var.include_app)
        error_message = "Valid value for variable 'include_app' is : 'yes' or 'no'"
      }
    }

    variable "app_instance_type" {
      description = "App Instance Type"
      type        = string
      default     = "t3a.micro"
    }

    variable "setup_migration" {
      description = "'yes' or 'no' to setup migration"
      type        = string
      default     = "yes"
      validation {
        condition = contains(["yes", "no"], var.setup_migration)
        error_message = "Valid value for variable 'setup_migration' is : 'yes' or 'no'"
      }
    }

    variable "owner" {
      description = "Owner of the infrastructure"
      type        = string
    }

    variable "project_id" {
      description = "project id to append to the owner.  This is the google project id from gcloud config get-value project"
      type        = string
    }

    # Optional tags
    variable "resource_tags" {
      description = "Tags to set for all resources"
      type        = map(string)
      default     = {}
    }

    variable "ansible_verbosity_switch" {
        description = "ansible level of messaging"
        type        = string
        default = "-v"
    }

    variable "mount_file_location" {
      description = "The mount point for large files.  Subdirectory of adminuser will be added as well"
      type        = string
      default     = "/mnt/data"
    }

    variable "crdb_version" {
      description = "CockroachDB Version"
      type        = string
      default     = "25.3.2"
    }
    variable "enable_privatelink" {
      description = "enable privatelink deployment"
      type        = bool
      default     = true
    }
    variable "cockroach_api_token" {
      description = "Cockroach Cloud API token (picks up from TF_VAR_cockroach_api_token)"
      type        = string
    }
    # Control whether to create a new cluster (true) or use an existing one (false)
    variable "create_cluster" {
      description = "If false, Terraform will not create a CockroachDB Cloud cluster but will import an existing one."
      type        = bool
      default     = true
    }
    
    # When create_cluster = false, this must be set to the ID of your existing cluster
    variable "existing_crdb_cluster_id" {
      description = "ID of an already‐provisioned CockroachDB Cloud cluster to manage."
      type        = string
      default     = ""
    }
# when importing, you must supply the cluster cert
variable "crdb_cluster_cert" {
  description = "PEM-encoded cluster CA cert (used when create_cluster = false)"
  type        = string
  default     = ""
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

variable "cockroach_server" {
  description = "Cockroach Cloud API server for the URL(picks up from TF_VAR_cockroach_server)"
  type        = string
}

variable "use_trusted_owners" {
  description = "use trusted owners on this cockroachdb account"
  type        = bool
  default     = false
}

variable "byoc_enabled" {
  description = "Enable BYOC; include a customer_cloud_account.gcp block"
  type        = bool
  default     = false
}

variable "byoc_gcp_account_id" {
  description = "Your GCP account ID that will host the BYOC cluster"
  type        = string
  default     = null
}

variable "byoc_gcp_role_arn" {
  description = "Cross-account IAM role ARN Cockroach Cloud will assume (trusts CRL control-plane)"
  type        = string
  default     = null
}
variable "gcp_credentials_file" {
  description = "Path to your Google Cloud ADC JSON file"
  type        = string
}

variable "gcp_account_id" {
  description = "GCP project that hosts the CockroachDB service attachment use getClusters to retrieve this account_id"
  type        = string
  default     = ""
}


# ----------------------------------------
# Kafka Instance Specifications
# ----------------------------------------
    variable "include_kafka" {
      description = "'yes' or 'no' to include an kafka Instance"
      type        = string
      default     = "yes"
      validation {
        condition = contains(["yes", "no"], var.include_kafka)
        error_message = "Valid value for variable 'include_kafka' is : 'yes' or 'no'"
      }
    }

    variable "kafka_instance_type" {
      description = "Kafka Instance Type"
      type        = string
      default     = "t3a.small"
    }
