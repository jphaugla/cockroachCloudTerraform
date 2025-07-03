# create a user name of alfred with the password from the newpassword.json file
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
USER_NAME=alfred
curl --request POST \
--url "https://cockroachlabs.cloud/api/v1/clusters/${CLUSTER_ID}/sql-users/${USER_NAME}/password" \
--header "Authorization: Bearer ${COCKROACH_API_TOKEN}" \
--header "Cc-Version: 2024-09-16" \
--json @newpassword.json
