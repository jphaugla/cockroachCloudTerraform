# setEnv.sh
# Azure resource scoping
export RG=jphauglblahdb-rg
export LOC=centralus
export VNET=jphauglblahdb-network
export SUBNET=jphauglblahdb-private-0

# CockroachDB Cloud values
export CRDB_ALIAS=/subscriptions/df1e53d1blah1-4b1cblah2-blah7442aeb8/resourceGroups/mc_crl-staging-zzzz-centralus_crdb_centralus/providers/Microsoft.Network/privateLinkServices/pls-adblahcada0fblah79d5dbd685blahdd
export CRDB_PLS_ID=${CRDB_ALIAS}
export CRDB_INTERNAL_DNS=internal-byoc-jph-azure-1-xxxx.azure-centralus.crdb.io

# Names you choose
export PE_NAME=crdb-pe
export PE_CONN_NAME=crdb-pe-conn
export DNS_LINK_NAME=crdb-dnslink
export ZONE_GROUP_NAME=crdb-zone-group

