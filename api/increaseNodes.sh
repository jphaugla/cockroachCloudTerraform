CLUSTER_ID=$1
curl --request PATCH \
  --url https://cockroachlabs.cloud/api/v1/clusters/${CLUSTER_ID} \
  --header 'Authorization: Bearer {secret_key}' \
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

