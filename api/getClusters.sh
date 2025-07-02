curl --request GET \
  --url https://cockroachlabs.cloud/api/v1/clusters \
  --header "Authorization: Bearer $COCKROACH_API_TOKEN" \
  --header "Cc-Version: 2024-09-16"
