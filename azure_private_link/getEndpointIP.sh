NIC_ID=$(az network private-endpoint show -g "$RG" -n "$PE_NAME" \
  --query 'networkInterfaces[0].id' -o tsv)

echo "NIC_ID is ${NIC_ID}"
PEP_IP=$(az network nic show --ids "$NIC_ID" \
  --query 'ipConfigurations[0].privateIPAddress' -o tsv)

echo "Private Endpoint NIC IP: $PEP_IP"

