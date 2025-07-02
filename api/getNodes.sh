CLUSTER_ID=$1
curl --request GET \
--url "https://cockroachlabs.cloud/api/v1/clusters/${CLUSTER_ID}/nodes" \
--header "Authorization: Bearer $COCKROACH_API_TOKEN" \
--header "Cc-Version: 2024-09-16"
