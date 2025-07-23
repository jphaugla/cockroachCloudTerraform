COCKROACH_SERVICE_NAME=jphaugla-api
# get the nodes for the cluster
if [[ -z "${CLUSTER_ID}" ]]; then
    echo "CLUSTER_ID is unset or empty."
else
    echo "CLUSTER_ID is set and not empty."
fi
if [[ -z "${COCKROACH_API_TOKEN}" ]]; then
    echo "COCKROACH_API_TOKEN is unset or empty."
else
    echo "COCKROACH_API_TOKEN is set and not empty."
fi
if [[ -z "${SA_ID}" ]]; then
    echo "SA_ID is unset or empty."
else
    echo "SA_ID is set and not empty."
fi
curl --request POST \
--url "https://cockroachlabs.cloud/api/v1/service-accounts/${SA_ID}/credentials" \
--header "Authorization: Bearer $COCKROACH_API_TOKEN" \
--header "Cc-Version: 2024-09-16" \
--header "Content-Type: application/json" \
--data '{}' 

