# get detailed information about the cluster
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
curl --request GET \
--url "https://${API_URL}/api/v1/clusters/${CLUSTER_ID}/connection-string?database=defaultdb&sql_user=jhaugland&os=MAC" \
--header "Authorization: Bearer $COCKROACH_API_TOKEN" \
--header "Cc-Version: 2024-09-16"
