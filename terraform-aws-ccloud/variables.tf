# variables.tf

variable "folder_path" {
  description = "Absolute path to the Cockroach Cloud folder (e.g. \"/prod/team1\")"
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider for the cluster"
  type        = string
  default     = "AWS"
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

variable "aws_region_list" {
  description = "List of three AWS regions to deploy CockroachDB (e.g. [\"us-east-1\",\"us-west-2\",\"us-east-2\"])."
  type        = list(string)
  default     = ["us-east-1", "us-west-2", "us-east-2"]
}

variable "aws_instance_keys" {
  description = "List of three EC2 Key Pair names—one per region, in the same order as aws_region_list."
  type        = list(string)
  default     = [
    "nollen-cockroach-us-east-1-kp01",
    "nollen-cockroach-us-west-2-kp01",
    "nollen-cockroach-us-east-2-kp01"
  ]
}

variable "ssh_private_key_list" {
  description = "List of three local paths to the private key files—one per region, matching aws_instance_keys."
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

variable "aws_config" {
   description = "aws config file"
   type        = list(string)
}

variable "aws_credentials" {
   description = "aws credentials directory"
   type        = list(string)
}


variable "node_count" {
   description = "the number of nodes"
   type        = number
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
      default     = "25.2.1"
    }
    variable "enable_private_dns" {
      description = "Whether to turn on AWS PrivateLink Private DNS"
      type        = bool
      default     = false
    }
variable "cockroach_api_token" {
  description = "Cockroach Cloud API token (picks up from TF_VAR_cockroach_api_token)"
  type        = string
}

