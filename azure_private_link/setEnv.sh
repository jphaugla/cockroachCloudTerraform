# setEnv.sh
# Azure resource scoping
# Azure resource group.  Should be built from the owner and resource name variables with static suffix
export RG=jphaugla-crdb-rg
export VNET=jphaugla-crdb-network
export SUBNET=jphaugla-crdb-private-0
# this is the azure region
export LOC=eastus2

# CockroachDB Cloud values
# this is the resource ID from cockroach cloud *Add a private Endpoint" screen that you copied while creeating the endpoint
export CRDB_ALIAS="/subscriptions/d8e15818-81c9-4f58-a361-8ab665210014/resourceGroups/mc_crl-prod-nqq-eastus2_crdb_eastus2/providers/Microsoft.Network/privateLinkServices/pls-a18f9f07eb39540b4a65df3a283d78e0"
export CRDB_PLS_ID=${CRDB_ALIAS}
# this value can be found using the api script getClusters.sh
export CRDB_INTERNAL_DNS=internal-jphaugla-crdb-adv-nqq.azure-eastus2.cockroachlabs.cloud

# Names you choose
export PE_NAME=crdb-pe
export PE_CONN_NAME=crdb-pe-conn
export DNS_LINK_NAME=crdb-dnslink
export ZONE_GROUP_NAME=crdb-zone-group
