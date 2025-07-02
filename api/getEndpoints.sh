# can get cluster id by going to 
CLUSTER_ID=$1
curl --request GET \
--url "https://cockroachlabs.cloud/api/v1/clusters/${CLUSTER_ID}"/private-endpoints \
--header "Authorization: Bearer $COCKROACH_API_TOKEN" \
--header "Cc-Version: 2024-09-16"
