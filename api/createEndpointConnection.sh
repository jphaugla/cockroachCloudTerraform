if [[ -z "${COCKROACH_API_TOKEN}" ]]; then
    echo "COCKROACH_API_TOKEN is unset or empty."
else
    echo "COCKROACH_API_TOKEN is set and not empty."
fi
if [[ -z "${CLUSTER_ID}" ]]; then
    echo "CLUSTER_ID is unset or empty."
else
    echo "CLUSTER_ID is set and not empty."
fi
if [[ -z "${API_URL}" ]]; then
    echo "API_URL is unset or empty."
else
    echo "API_URL is set and not empty."
    echo ${API_URL}
fi
VPC_ENDPOINT_ID=vpce-05fc03a2142f485f8

curl -s -X POST "https://${API_URL}/api/v1/clusters/${CLUSTER_ID}/networking/private-endpoint-connections" \
  -H "Authorization: Bearer ${COCKROACH_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -H "Cc-Version: 2024-09-16" \
  -d "{\"endpoint_id\":\"${VPC_ENDPOINT_ID}\"}"

