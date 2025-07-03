# Cockroach Cloud Terraform

This repository contains Terraform/Ansible configurations to provision and manage a CockroachDB Advanced cluster on Cockroach Cloud, along with the necessary AWS infrastructure for PrivateLink connectivity and an application node.

## Repository Structure

### Directory Structure

- **ansible**:  Contains the ansible tasks for deploying the application node.
  - Works for both AWS and Azure deployments
- **AWS**
  - **terraform-aws-app**:  terraform for aws application node
    - The terraform files in **terraform-aws-app** create the networking for an application node and private link definitions 
  - **terraform-aws-ccloud**:  terraform for cockroach cloud aws
    - The terraform files in **terraform-aws-ccloud** define the cockroach cloud cluster and also initiate an application server for each of the defined regions.   
- **Azure**
    - **terraform-azure-app**:  terraform for azure application node
        - The terraform files in **terraform-azure-app** create the networking for an application node 
        - In azure, private link definitions need to be done in the Azure UI as terraform doesn't work
    - **terraform-azure-ccloud**:  terraform for cockroach cloud azure
        - The terraform files in **terraform-azure-ccloud** define the cockroach cloud cluster 
        - In azure, initiating the application server for each of the defined regions is a separate deployment
- File names used across these directories
  - **providers.tf**: Configures Terraform providers for AWS and CockroachDB.
  - **variables.tf, vars.tf**: Declares all input variables for customizing the deployment.
  - **locals.tf**: Defines computed values and fallbacks (e.g., `effective_regions`).
  - **sg_application.tf, sg_intra.tf, sg_management.tf, network-sg.tf**: Security Group modules.
  - **network.tf**: Application network components.
  - **storage.tf**: Cloud storage components.
  - **inventory.tf**: Capture inventory information from terraform for ansible 
  - **privatelink.tf**: Resources to expose, connect, and trust the CockroachDB PrivateLink service:
    - `cockroach_private_endpoint_services`
    - `aws_vpc_endpoint`
    - `cockroach_private_endpoint_trusted_owner`
    - `cockroach_private_endpoint_connection`
  - **cluster.tf**: CockroachDB cluster, allow‑list entries, and SQL user creation.
  - **outputs.tf**: Exposes useful values such as `crdb_sql_dns` and application connection strings.

## Prerequisites

1. **Terraform**: v1.5+ installed.
2. Depending on AWS or azure, set the environment
   - **AWS credentials**: Configure via environment variables or `~/.aws/credentials`.
   - **Azure credentials**: az login
3. **Cockroach Cloud API TOKEN**:
   ```bash
export COCKROACH_API_TOKEN=CCDB1_BLAHkjC2MBLAHXGZ6SyyYc_BLAHULj7mwmBLAHz3I84svqdBLAHchx33InBLAH
export TF_VAR_cockroach_api_token="${COCKROACH_API_TOKEN}"
   ```

## Quick Start for AWS
NOTES: 
- the control file for this is  terraform-aws-ccloud/aws-multi/main.tf 
       because of the private links in the terraform, an extra apply is needed
- eventually, will add a single region folder  terraform-aws-ccloud/aws-single/main.tf 

1. **change to correct directory**
   ```bash
   cd terraform-aws-ccloud/aws-multi
   ```
2. **set enable_private_dns to false**
- edit main.tf to set enable_private_dns = false
- set all the other parameters for the deployment in main.tf
- ensure the COCKROACH_API_TOKEN environment variables are set

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

- This is taken care of in a script placed in the application node at:  **/home/ec2-user/sql.sh**
- Otherwise, on your EC2 app host, set:

```bash
export DATABASE_URL="postgresql://<user>:<pass>@$(terraform output -raw crdb_sql_dns):26257/defaultdb?sslmode=verify-full&sslrootcert=/home/ec2-user/certs/ca.crt"
cockroach sql --url="$DATABASE_URL"
```
## Quick Start for Azure
NOTES:
- Unlike AWS, the cluster creation and the application server creation are two completely separate terraform processes
- Azure terraform doesn't effectively handle the private link steps so these steps need to be done manually
- Outputs from the cluster creation terraform are used for the application deployment
- the control file for the cluster is terraform-azure-ccloud/cluster-only/main.tf
- the control file for the application side is terraform-azure-app/app-only/main.tf

1. **change to correct directory**
   ```bash
   cd terraform-azure-ccloud/cluster-only
   ```
2. **set enable_private_dns to false**
   - edit main.tf to set specific values for the deployment
   - ensure the COCKROACH_API_TOKEN environment variables are set

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
6. Follow documented steps to create a private link in cockroach cloud and create DNS
7. **change to correct directory**
   ```bash
   cd terraform-azure-app/app-only
   ```
8.  **set enable_private_dns to false**
    - edit main.tf to set specific values for the deployment
    - ensure the COCKROACH_API_TOKEN environment variable is set
    - ensure the PE_Service ID environment variable is set
    - ensure crdb_private_endpoint_dns environment variable is set
9. **Initialize Terraform**
   ```bash
   terraform init
   ```
10. **Apply**
   ```bash
   terraform apply -auto-approve 
   ```

### Obtain PrivateLink DNS

The SQL DNS hostname is exposed as an output:

```bash
terraform output -raw crdb_sql_dns
```

This name resolves over Azure PrivateLink once the VPC endpoint’s private DNS is enabled.

### Connect From Application Node

- This is taken care of in a script placed in the application node at:  **/home/ec2-user/sql.sh**
- Otherwise, on your EC2 app host, set:

```bash
export DATABASE_URL="postgresql://<user>:<pass>@$(terraform output -raw crdb_sql_dns):26257/defaultdb?sslmode=verify-full&sslrootcert=/home/ec2-user/certs/ca.crt"
cockroach sql --url="$DATABASE_URL"
```

## Cleanup

To destroy everything:

```bash
terraform destroy -auto-approve
```
