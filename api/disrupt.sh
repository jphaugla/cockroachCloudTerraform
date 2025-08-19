# this is the wrapper disrupt script.  Pass the appropriate json file as the first parameter for the desired action
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
if [[ -z "${API_URL}" ]]; then
    echo "API_URL is unset or empty."
else
    echo "API_URL is set and not empty."
    echo ${API_URL}
fi
if [ -z "$1" ]; then
  echo "Error: The first parameter is not set or is empty. First parameter must contain the name of the json disruption file"
  exit 1
else
  echo "The json file is set to: $1"
fi
JSON_FILE=$1
echo "the json file ${JSON_FILE} contains:"
cat ${JSON_FILE}
curl --request PUT \
--url "https://${API_URL}/api/v1/clusters/${CLUSTER_ID}/disrupt" \
--header "Authorization: Bearer ${COCKROACH_API_TOKEN}" \
--data @${JSON_FILE}
