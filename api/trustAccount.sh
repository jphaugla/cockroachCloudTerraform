if [[ -z "${COCKROACH_API_TOKEN}" ]]; then
    echo "COCKROACH_API_TOKEN is unset or empty."
else
    echo "COCKROACH_API_TOKEN is set and not empty."
fi
if [[ -z "${ACCOUNT_ID}" ]]; then
    echo "ACCOUNT_ID is unset or empty."
else
    echo "ACCOUNT_ID is set and not empty."
fi
if [[ -z "${API_URL}" ]]; then
    echo "API_URL is unset or empty."
else
    echo "API_URL is set and not empty."
    echo ${API_URL}
fi
curl --request POST \
  --url "https://${API_URL}/api/v1/clusters/${CLUSTER_ID}/private-endpoint-trusted" \
  --header "Authorization: Bearer $COCKROACH_API_TOKEN" \
  --header "Cc-Version: 2024-09-16" \
  --header "Content-Type: application/json" \
  -d "{\"type\":\"AWS_ACCOUNT_ID\",\"external_owner_id\":\"${AWS_ACCOUNT_ID}\"}"
