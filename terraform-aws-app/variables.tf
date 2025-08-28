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

variable "run_ansible" {
   description = "run the ansible"
   type        = bool
   default     = true
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

# ---------------------------
# inventory files
# --------------------------
    variable "instances_inventory_file" {
        description = "File name to send inventory details for ansible later. this is relative to the calling main.tf file"
        type        = string
        default = "../inventory"
    }

    variable "playbook_working_directory" {
        description = "Path for the working directory"
        type        = string
        default = "../../ansible"
    }

    variable "playbook_instances_inventory_file" {
        description = "Path for the playbook command to use for the instances inventory file"
        type        = string
        default = "../terraform-aws-app/inventory"
    }

    variable "instances_inventory_directory" {
        description = "Path for the inventory directory, this is relative to playbook_working_directory"
        type        = string
        default = "../temp/"
    }

    variable "inventory_template_file" {
        description = "File name and Path to for inventory template file."
        type        = string
        default = "../terraform-aws-app/templates/inventory.tpl"
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
 variable "prometheus_string" {
      description = "The prometheus string to use at start-up.  Do not supply a value"
      type        = string
      default     = ""
    }

    variable "prometheus_app_string" {
      description = "The  prometheus string to use at start-up.  Do not supply a value"
      type        = string
      default     = ""
    }

    variable "cockroach_api_token" {
      description = "Cockroach Cloud API token (picks up from TF_VAR_cockroach_api_token)"
      type        = string
    }

    variable "crdb_cloud_url" {
      description = "Cockroach Cloud API url"
      type        = string
      default     = "cockroachlabs.cloud"
    }

    variable "create_iam_resources" {
      type        = bool
      description = "Whether to create IAM role and instance profile for EC2"
      default     = false
    }
