JSON_FILE=restore.json
CLUSTER_ID=$1
curl --request PUT \
--url "https://cockroachlabs.cloud/api/v1/clusters/${CLUSTER_ID}/disrupt" \
--header "Authorization: Bearer ${COCKROACH_API_TOKEN}" \
--data @${JSON_FILE}
