# addArecord.sh
NIC_ID=$(az network private-endpoint show -g "$RG" -n "$PE_NAME" \
  --query 'networkInterfaces[0].id' -o tsv)

echo "NIC_ID is ${NIC_ID}"
PEP_IP=$(az network nic show --ids "$NIC_ID" \
  --query 'ipConfigurations[0].privateIPAddress' -o tsv)

echo "Private Endpoint NIC IP: $PEP_IP"

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
    --ipv4-address "$PEP_IP"
fi

echo "A record created: $CRDB_INTERNAL_DNS -> $PEP_IP"

