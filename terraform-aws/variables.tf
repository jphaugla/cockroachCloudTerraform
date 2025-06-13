# variables.tf

variable "folder_path" {
  description = "Absolute path to the Cockroach Cloud folder (e.g. \"/prod/team1\")"
  type        = string
}


variable "env_file" {
  description = "Path to the shell file exporting COCKROACH_API_KEY and COCKROACH_API_TOKEN"
  type        = string
  default     = "~/.cockroachCloud/setEnv.sh"
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

variable "cidr" {
  description = "cidr for the EKS cluster"
  type        = string
}

variable "run_k8s_cockroach" {
   description = "run the cockroach deployment in ansible"
   type        = string
}


variable "kubeconfig" {
   description = "location for the kubeconfig file"
   default = "/Users/jasonhaugland/.kube/config"
   type        = string
}

variable "aws_region" {
   description = "aws region to use"
   type        = string
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
      default     = ""
    }

    variable "project_name" {
      description = "project name to append to the owner"
      type        = string
      default     = ""
    }

    # Optional tags
    variable "resource_tags" {
      description = "Tags to set for all resources"
      type        = map(string)
      default     = {}
    }

    variable "instance_key_name" {
      description = "instance key name for the application node-this is name and not full path"
      type        = string
      default     = ""
    }
    variable "ssh_private_key" {
      description = "full instance key path for the application node"
      type        = string
      default     = ""
    }
