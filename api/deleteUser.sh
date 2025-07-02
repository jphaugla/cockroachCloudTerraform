CLUSTER_ID=$1
USER_NAME=$2
curl --request DELETE \
--url "https://cockroachlabs.cloud/api/v1/clusters/${CLUSTER_ID}/sql-users/${USER_NAME}" \
--header "Authorization: Bearer $COCKROACH_API_TOKEN" \
--header "Cc-Version: 2024-09-16" 
