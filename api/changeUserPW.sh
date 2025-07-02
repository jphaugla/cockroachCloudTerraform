CLUSTER_ID=$1
USER_NAME=alfred
curl --request POST \
--url "https://cockroachlabs.cloud/api/v1/clusters/${CLUSTER_ID}/sql-users/${USER_NAME}/password" \
--header "Authorization: Bearer $COCKROACH_API_TOKEN" \
--header "Cc-Version: 2024-09-16" \
--json @newpassword.json
