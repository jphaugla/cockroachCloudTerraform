VPC_ENDPOINT_ID=vpce-05fc03a2142f485f8

curl -s -X POST "https://${API_URL}/api/v1/clusters/${CLUSTER_ID}/private-endpoint-connections" \
  -H "Authorization: Bearer ${COCKROACH_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"endpoint_id\":\"${VPC_ENDPOINT_ID}\"}"
