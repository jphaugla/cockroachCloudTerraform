RG=jphaugla-crdb-rg
ZONE=privatelink.servicebus.windows.net
NAME=jphaugla-crdb-ehns
PE_IP=192.168.3.4

# Does the zone exist?
az network private-dns zone show -g "$RG" -n "$ZONE" -o table

# Is the VNet linked?
az network private-dns link vnet list -g "$RG" -z "$ZONE" -o table

# Do we already have the A record?
az network private-dns record-set a show -g "$RG" -z "$ZONE" -n "$NAME" -o json \
  --query 'aRecords[].ipv4Address'

# If missing, create it:
# az network private-dns record-set a create -g "$RG" -z "$ZONE" -n "$NAME"
# az network private-dns record-set a add-record -g "$RG" -z "$ZONE" -n "$NAME" --ipv4-address "$PE_IP"

