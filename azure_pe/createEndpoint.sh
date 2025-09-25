#!/usr/bin/env bash
# createEndpoint.sh
set -euo pipefail

# (recommended) allow PEs in the subnet
az network vnet subnet update \
  -g "${RG}" --vnet-name "${VNET}" --name "${SUBNET}" \
  --disable-private-endpoint-network-policies true >/dev/null

# Create PE to Cockroach's Private Link Service
az network private-endpoint create \
  --name "${PE_NAME}" \
  --resource-group "${RG}" \
  --location "${LOC}" \
  --vnet-name "${VNET}" \
  --subnet "${SUBNET}" \
  --connection-name "${PE_CONN_NAME}" \
  --private-connection-resource-id "${CRDB_PLS_ID}" \
  --manual-request true \
  --request-message "CRDB PE from ${RG}/${VNET}"

# Show the PE resource ID (paste this in Cockroach UI -> Validate)
az network private-endpoint show -g "$RG" -n "$PE_NAME" --query id -o tsv

