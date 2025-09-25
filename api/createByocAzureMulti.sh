if [[ -z "${COCKROACH_API_TOKEN}" ]]; then
    echo "COCKROACH_API_TOKEN is unset or empty."
else
    echo "COCKROACH_API_TOKEN is set and not empty."
fi
if [[ -z "${ARM_SUBSCRIPTION_ID}" ]]; then
    echo "ARM_SUBSCRIPTION_ID is unset or empty."
else
    echo "ARM_SUBSCRIPTION_ID is set and not empty."
    echo "${ARM_SUBSCRIPTION_ID}"
fi
if [[ -z "${API_URL}" ]]; then
    echo "API_URL is unset or empty."
else
    echo "API_URL is set and not empty."
    echo "${API_URL}"
fi
if [[ -z "${APP_OBJECT_ID}" ]]; then
    echo "APP_OBJECT_ID is unset or empty."
else
    echo "APP_OBJECT_ID is set and not empty."
    echo "${APP_OBJECT_ID}"
fi
if [[ -z "${TENANT_ID}" ]]; then
    echo "TENANT_ID is unset or empty."
else
    echo "TENANT_ID is set and not empty."
    echo "${TENANT_ID}"
fi
curl --request POST \
  --url https://${API_URL}/api/v1/clusters \
  --header "Authorization: Bearer ${COCKROACH_API_TOKEN}" \
  --header "Cc-Version: 2024-09-16" \
  --header "Content-Type: application/json" \
  --data @- <<EOF
{
  "name": "byoc-jph-azure-multi",
  "plan": "ADVANCED",
  "provider": "AZURE",
  "spec": {
    "customer_cloud_account_details": {
      "azure": {
        "subscription_id": "${ARM_SUBSCRIPTION_ID}",
        "tenant_id": "${TENANT_ID}",
        "crl_app_object_id": "${APP_OBJECT_ID}"
      }
    },
    "dedicated": {
      "hardware": {
        "machine_spec": { "num_virtual_cpus": 4 },
        "storage_gib": 16
      },
      "region_nodes": { "centralus": 3,
			"canadacentral": 3,
                        "australiaeast": 3 }
    }
  }
}
EOF
