# adjust the number of nodes in a region
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
curl --request PATCH \
  --url https://cockroachlabs.cloud/api/v1/clusters/${CLUSTER_ID} \
  --header 'Authorization: Bearer ${COCKROACH_API_TOKEN}' \
  --header 'Cc-Version: 2024-09-16' \
  --json '{
    "spec": {
      "dedicated": {
        "region_nodes": {
          "us-west-2": 4
        }
      }
    }
  }'
