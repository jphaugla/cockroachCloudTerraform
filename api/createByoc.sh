if [[ -z "${COCKROACH_API_TOKEN}" ]]; then
    echo "COCKROACH_API_TOKEN is unset or empty."
else
    echo "COCKROACH_API_TOKEN is set and not empty."
    echo "${COCKROACH_API_TOKEN}"
fi
if [[ -z "${ACCOUNT_ID}" ]]; then
    echo "ACCOUNT_ID is unset or empty."
else
    echo "ACCOUNT_ID is set and not empty."
    echo "${ACCOUNT_ID}"
fi
if [[ -z "${API_URL}" ]]; then
    echo "API_URL is unset or empty."
else
    echo "API_URL is set and not empty."
    echo "${API_URL}"
fi
curl --request POST \
  --url https://${API_URL}/api/v1/clusters \
  --header "Authorization: Bearer $COCKROACH_API_TOKEN" \
  --header "Cc-Version: 2024-09-16" \
  --header "Content-Type: application/json" \
  --data @- <<EOF
{
  "name": "byoc-jph-1",
  "plan": "ADVANCED",
  "provider": "AWS",
  "spec": {
    "customer_cloud_account_details": {
      "aws": {
        "arn": "arn:aws:iam::${ACCOUNT_ID}:role/CRLBYOCAdmin"
      }
    },
    "dedicated": {
      "hardware": {
        "machine_spec": { "num_virtual_cpus": 4 },
        "storage_gib": 15
      },
      "region_nodes": { "us-east-2": 3 }
    }
  }
}
EOF

