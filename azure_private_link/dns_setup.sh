# dns_setup.sh
az network private-dns zone create -g "$RG" -n "$CRDB_INTERNAL_DNS"

az network private-dns link vnet create \
  -g "$RG" --zone-name "$CRDB_INTERNAL_DNS" \
  -n "$DNS_LINK_NAME" --virtual-network "$VNET" \
  --registration-enabled false

az network private-endpoint dns-zone-group create \
  -g "$RG" --endpoint-name "$PE_NAME" \
  -n "$ZONE_GROUP_NAME" \
  --private-dns-zone "$CRDB_INTERNAL_DNS" \
  --zone-name "cockroachdb"
