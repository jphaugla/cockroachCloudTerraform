# Cockroach Cloud Terraform

This repository contains Terraform/Ansible configurations to provision and manage a CockroachDB Advanced cluster on Cockroach Cloud, along with the necessary AWS infrastructure for PrivateLink connectivity and an application node.

## Repository Structure

### Directory Structure

- **ansible**:  Contains the ansible tasks for deploying the application node
- **terraform-aws-app**:  terraform for aws application node
The terraform files in **terraform-aws-app** create the networking for an application node, an application node, and private link definitions 
- **terraform-aws-ccloud**:  terraform for cockroach cloud
The terraform files in **terraform-aws-ccloud** define the cockroach cloud cluster and also initiate an application server for each of the defined regions.   

- **providers.tf**: Configures Terraform providers for AWS and CockroachDB.
- **variables.tf**: Declares all input variables for customizing the deployment.
- **locals.tf**: Defines computed values and fallbacks (e.g., `effective_regions`).
- **sg_application.tf, sg_intra.tf, sg_management.tf**: Security Group modules.
- **network.tf**: Application network components.
- **privatelink.tf**: Resources to expose, connect, and trust the CockroachDB PrivateLink service:
  - `cockroach_private_endpoint_services`
  - `aws_vpc_endpoint`
  - `cockroach_private_endpoint_trusted_owner`
  - `cockroach_private_endpoint_connection`
- **cluster.tf**: CockroachDB cluster, allow‑list entries, and SQL user creation.
- **outputs.tf**: Exposes useful values such as `crdb_sql_dns` and application connection strings.

## Prerequisites

1. **Terraform**: v1.5+ installed.
2. **AWS credentials**: Configure via environment variables or `~/.aws/credentials`.
3. **Cockroach Cloud API Key**:
   ```bash
   export COCKROACH_API_KEY="<your_api_key>"
   ```

## Quick Start
NOTES: the control file for this is  terrafrom-aws-ccloud/test/main.tf 
       because of the private links in the terraform, an extra apply is needed

1. **get to correct directory**
   ```bash
   cd terrafrom-aws-ccloud/test
   ```
2. **set enable_private_dns to false**
edit main.tf to set enable_private_dns = false

3. **Initialize Terraform**
   ```bash
   terraform init
   ```
4. **Apply**
   ```bash
   terraform apply -auto-approve 
   ```
5. **accept the connection in cockroach cloud network**
In the cockroach cloud UI go to the Networking->Private endpoint page
Click on the actions dots and select "Finish setup"

6. **set enable_private_dns to true**
edit main.tf to set enable_private_dns = true

7. **repeat step 3 and 4**

### Obtain PrivateLink DNS

The SQL DNS hostname is exposed as an output:

```bash
terraform output -raw crdb_sql_dns
```

This name resolves over AWS PrivateLink once the VPC endpoint’s private DNS is enabled.

### Connect From Application Node

On your EC2 app host, set:

```bash
export DATABASE_URL="postgresql://<user>:<pass>@$(terraform output -raw crdb_sql_dns):26257/defaultdb?sslmode=verify-full&sslrootcert=/home/ec2-user/certs/ca.crt"
cockroach sql --url="$DATABASE_URL"
```

## Cleanup

To destroy everything:

```bash
terraform destroy -auto-approve
```

---
