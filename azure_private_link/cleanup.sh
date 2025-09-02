#!/usr/bin/env bash
# deleteEndpoint.sh
set -euo pipefail

# Expect these from your setEnv.sh (and optionally PE_IP)
: "${RG:?Missing RG}"; : "${PE_NAME:?Missing PE_NAME}"; : "${CRDB_INTERNAL_DNS:?Missing CRDB_INTERNAL_DNS}"
VNET="${VNET:-}"; SUBNET="${SUBNET:-}"
DNS_LINK_NAME="${DNS_LINK_NAME:-crdb-dnslink}"
ZONE_GROUP_NAME="${ZONE_GROUP_NAME:-crdb-zone-group}"
PE_IP="${PE_IP:-}"

# 1) Detach DNS zone group from the Private Endpoint (safe if absent)
az network private-endpoint dns-zone-group delete \
  -g "$RG" --endpoint-name "$PE_NAME" -n "$ZONE_GROUP_NAME" \
  --only-show-errors || true

# 2) Remove the A record for the PE (if you know the IP)
if [[ -n "$PE_IP" ]]; then
  az network private-dns record-set a remove-record \
    -g "$RG" -z "$CRDB_INTERNAL_DNS" -n "@" \
    --ipv4-address "$PE_IP" --only-show-errors || true
fi

# (Also remove the root record-set if now empty)
az network private-dns record-set a delete \
  -g "$RG" -z "$CRDB_INTERNAL_DNS" -n "@" \
  --yes --only-show-errors || true

# 3) Unlink the VNet from the private DNS zone
az network private-dns link vnet delete \
  -g "$RG" -z "$CRDB_INTERNAL_DNS" -n "$DNS_LINK_NAME" \
  --only-show-errors || true

# 4) Delete the private DNS zone itself
az network private-dns zone delete \
  -g "$RG" -n "$CRDB_INTERNAL_DNS" --yes \
  --only-show-errors || true

# 5) Delete the Private Endpoint
az network private-endpoint delete \
  -g "$RG" -n "$PE_NAME" \
  --only-show-errors || true

# 6) (Optional) Re-enable subnet PE network policies you disabled earlier
if [[ -n "$VNET" && -n "$SUBNET" ]]; then
  az network vnet subnet update \
    -g "$RG" --vnet-name "$VNET" --name "$SUBNET" \
    --disable-private-endpoint-network-policies false \
    --only-show-errors || true
fi

# 7) Show leftovers (if any)
echo "Remaining Private Endpoints in RG:"
az network private-endpoint list -g "$RG" -o table
echo "Remaining Private DNS zones in RG:"
az network private-dns zone list -g "$RG" -o table

