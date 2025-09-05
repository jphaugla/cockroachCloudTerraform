# someStatus.sh
az network private-endpoint show -g "$RG" -n "$PE_NAME" \
  --query 'manualPrivateLinkServiceConnections[].privateLinkServiceConnectionState' -o json
az network private-endpoint show -g "$RG" -n "$PE_NAME" \
  --query '[manualPrivateLinkServiceConnections[].{id:privateLinkServiceId,name:name,groupIds:groupIds,state:privateLinkServiceConnectionState}]' -o json
