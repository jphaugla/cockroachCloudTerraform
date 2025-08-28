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
export CRDB_ALIAS="/subscriptions/d8e1blah-81c9-blah-a361-blah652blah4/resourceGroups/mc_crl-blah-nqh-eastus2_blah_eblahs2/providers/Microsoft.Network/privateLinkServices/pls-blah6fa0blah8407a83bblahad1blah8"
export CRDB_PLS_ID=${CRDB_ALIAS}
# this value can be found using the api script getClusters.sh
export CRDB_INTERNAL_DNS=internal-jpblahla-crdb-ablahqblahure-eblahs2.cockroachlabs.cloud

# Names you choose
export PE_NAME=crdb-pe
export PE_CONN_NAME=crdb-pe-conn
export DNS_LINK_NAME=crdb-dnslink
export ZONE_GROUP_NAME=crdb-zone-group
