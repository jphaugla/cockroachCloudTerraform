# will delete the passed in user name.  must pass in the user name as the first parameter
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
if [ -z "$1" ]; then
  echo "Error: The first parameter is not set or is empty. First parameter must contain the user name to delete"
  exit 1
else
  echo "The username to delete is set to: $1"
fi
if [[ -z "${API_URL}" ]]; then
    echo "API_URL is unset or empty."
else
    echo "API_URL is set and not empty."
    echo ${API_URL}
fi
USER_NAME=$1
curl --request DELETE \
--url "https://${API_URL}/api/v1/clusters/${CLUSTER_ID}/sql-users/${USER_NAME}" \
--header "Authorization: Bearer $COCKROACH_API_TOKEN" \
--header "Cc-Version: 2024-09-16" 
