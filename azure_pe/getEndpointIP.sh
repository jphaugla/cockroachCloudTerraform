#!/usr/bin/env bash
set -euo pipefail

: "${RG:?RG env var required}"
: "${PE_NAME:?PE_NAME env var required}"

# Get the NIC ID attached to the Private Endpoint
PE_NIC_ID=$(az network private-endpoint show -g "$RG" -n "$PE_NAME" --query 'networkInterfaces[0].id' -o tsv)
echo "PE_NIC_ID: $PE_NIC_ID"

# Helper: read primary private IP from NIC
get_ip_from_nic() {
  # Prefer the primary ipConfiguration explicitly
  az network nic show --ids "$PE_NIC_ID" \
    --query "ipConfigurations[?primary].privateIPAddress | [0]" -o tsv
}

# Helper: fallback via Private Endpoint's custom DNS configs
get_ip_from_pe() {
  az network private-endpoint show -g "$RG" -n "$PE_NAME" \
    --query "customDnsConfigs[0].ipAddresses[0]" -o tsv
}

PE_IP=""
for i in {1..12}; do
  PE_IP=$(get_ip_from_nic || true)
  if [[ -n "${PE_IP}" && "${PE_IP}" != "null" ]]; then
    break
  fi

  PE_IP=$(get_ip_from_pe || true)
  if [[ -n "${PE_IP}" && "${PE_IP}" != "null" ]]; then
    break
  fi

  sleep 5
done

if [[ -z "${PE_IP}" || "${PE_IP}" == "null" ]]; then
  echo "ERROR: Private IP not found after waiting. Dumping NIC for debugging..." >&2
  az network nic show --ids "$PE_NIC_ID" -o jsonc >&2
  exit 1
fi

echo "PE_IP=${PE_IP}"

