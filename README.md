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
        - In azure, private link definitions need to be done in the Azure UI or CLI  as terraform doesn't work
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

## Quick Start for AWS single or multi-region.  
NOTES: 
- the control file for this is  terraform-aws-ccloud/aws-multi/main.tf 
       because of the private links in the terraform, an extra apply is needed
- directions are same for terraform-aws-ccloud/aws-single/main.tf 
- there is also terraform-aws-ccloud/aws-defined/main.tf for using an existing cluster and just adding the connected kafka and application nodes but this is not fully tested yet

1. **change to correct directory**
   ```bash
   cd terraform-aws-ccloud/aws-multi
       or
   cd terraform-aws-ccloud/aws-single
   ```
2. **set enable_private_dns to false**
- edit main.tf to set enable_private_dns = false
- set all the other parameters for the deployment in main.tf
- ensure the COCKROACH_API_TOKEN and TF_VAR_cockroach_api_token environment variables are set
- ensure aws project information is set up 

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

7. **repeat step 3**

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
- Azure terraform doesn't effectively handle the private link steps so these steps need to be done manually in the azure UI or the azure CLI
- Outputs from the cluster creation terraform are used for the application deployment
- the control file for the cluster is terraform-azure-ccloud/cluster-only/main.tf
  * this only creates the cockroach cloud cluster and does not create application server or the network for the application server.
- the control file for the application side is terraform-azure-app/app-only/main.tf

### change to correct directory
   ```bash
   cd terraform-azure-ccloud/cluster-only
   ```
### prepare main.tf
   - edit main.tf to set specific values for the deployment
   - ensure the COCKROACH_API_TOKEN environment variables are set
### Initialize Terraform
   ```bash
   terraform init
   ```
### Apply
   ```bash
   terraform apply -auto-approve 
   ```
NOTE:  When this terraform apply is complete, there is a cockroach cloud instance that can be observed in cockroach cloud
### create the privatelink network connection in cockroach cloud UI
   In the cockroach cloud UI go to the Networking->Private endpoint page
   Click *Add a private endpoint* and follow directions to copy this Resource ID as it will be needed to define the private endpoint and dns in azure
### Kick off terraform to create the network and application servers to interact with cockroach cloud cluster
   * adjust main.tf for your environment such as your ip address, CIDR, crdb_version, ssh_key_name (must be pre-created)
   * important:  **set enable_private_dns to false**
   ```bash
   cd terraform-azure-app/app-only
   ```
   * *Initialize Terraform*
   ```bash
   terraform init
   ```
   * *Apply*
   ```bash
   terraform apply -auto-approve 
   ```
NOTE:  When this terraform apply is complete, there is a application server, kafka server and a network
### Create Azure Privatelink and DNS 
* Use CLI scripts provided in [azure_private_link subdirectory](azure_private_link) or follow [documented steps to create a privatelink and DNS in your azure account](https://www.cockroachlabs.com/docs/cockroachcloud/connect-to-an-advanced-cluster#azure-private-link).  
   * To use the [azure_private_link subdirectory](azure_private_link) steps:
     * Adjust environment variables in the [setEnv.sh](setEnv.sh).  Crucial to enter the correct paramaters that match the network and the values from the current environment using [getClusters.sh](api/getClusters.sh).
   ```bash
   cd azure_private_link
   source setEnv.sh
   ./createEndpoint.sh
   ./dns_setup.sh
   ./addArecord.sh
   ```
### Run the ansible to install application server, kafka, and prometheus with connectivity to cockroach cloud cluster
    * edit main.tf to set specific values for the deployment
    * ensure the COCKROACH_API_TOKEN environment variable is set
    * important:  **set enable_private_dns to true**
    * ensure crdb_private_endpoint_dns environment variable is set
    * *Initialize Terraform*
   ```bash
   terraform init
   ```
    * *Apply*
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

## Using the API
A [set of scripts](api) is included for interacting with the Cockroach Cloud API.
* [This is the CockroachDB Cloud API documentation](https://www.cockroachlabs.com/docs/api/cloud/v1.html#overview)
* The following environment variables need to be set up to use the API scripts:
```bash
export COCKROACH_API_TOKEN=CCDB1_QRblahdlNKaDblahmzxyV3_1EmWcSblahrN1i7xi9SzNEblahcoc0gPrx0blahd
export API_URL=cockroachlabs.cloud
export ACCOUNT_ID=986753099999
# add the cluster id after retrieving it with api/clusters.sh
export CLUSTER_ID=7bef2blah528f-4blahb15f-bblah26b961d
# only needed on a few scripts
export SA_ID=4f955377-blah-400b-blah-blah146fblah
``` 
## Cleanup
Before destroy, drop the sql  user name that is created (example is jhaugland).  Without dropping the user, the destroy cluster will fail.

```bash
drop owned by jhaugland;
DROP DATABASE IF EXISTS ecommerce CASCADE;
DROP DATABASE IF EXISTS employees CASCADE;
DROP DATABASE IF EXISTS kv CASCADE;
drop user jhaugland;
```
check for any other databases by doing *SHOW DATABASES*.   drop any of those databases if owned by jhaugland

To destroy everything:

```bash
terraform destroy -auto-approve
```
