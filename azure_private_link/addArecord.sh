PE_IP="192.168.3.4"

# ensure the record set exists
az network private-dns record-set a create \
  -g "$RG" -z "$CRDB_INTERNAL_DNS" -n "@" >/dev/null || true

# add the PE IP (skip if it’s already there)
EXISTING_IPS=$(az network private-dns record-set a show \
  -g "$RG" -z "$CRDB_INTERNAL_DNS" -n "@" \
  --query 'arecords[].ipv4Address' -o tsv 2>/dev/null || true)

if [[ "$EXISTING_IPS" != *"$PE_IP"* ]]; then
  az network private-dns record-set a add-record \
    -g "$RG" -z "$CRDB_INTERNAL_DNS" -n "@" \
    --ipv4-address "$PE_IP"
fi

echo "A record created: $CRDB_INTERNAL_DNS -> $PE_IP"

