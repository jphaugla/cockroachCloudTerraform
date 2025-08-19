curl -s "https://${API_URL}/api/v1/clusters/${CLUSTER_ID}/networking/private-endpoint-connections" \
  -H "Authorization: Bearer ${COCKROACH_API_TOKEN}" \
  -H "Cc-Version: 2024-09-16" | jq -r \
  '.connections[]?|select(.endpoint_id=="vpce-05fc03a2142f485f8")|.status'
