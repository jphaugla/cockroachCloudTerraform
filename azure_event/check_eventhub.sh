RG=jphaugla-crdb-rg
NAMESPACE=jphaugla-crdb-ehns
# Expect: Disabled
az eventhubs namespace show -g ${RG} -n ${NAMESPACE} --query publicNetworkAccess -o tsv
az eventhubs namespace network-rule-set show -g ${RG} -n ${NAMESPACE}

# Quick DNS sanity
nslookup "${NAMESPACE}.servicebus.windows.net"

