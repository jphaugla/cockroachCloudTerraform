#!/usr/bin/env bash
set -euo pipefail

# Required env vars:
#   CRDB_CLOUD_URL, CLUSTER_ID, COCKROACH_API_TOKEN, BODY_FILE

API_URL="${CRDB_CLOUD_URL:?CRDB_CLOUD_URL is required}"
CLUSTER_ID="${CLUSTER_ID:?CLUSTER_ID is required}"
TOKEN="${COCKROACH_API_TOKEN:?COCKROACH_API_TOKEN is required}"
BODY_FILE="${BODY_FILE:?BODY_FILE is required}"

resp="$(mktemp)"
code=$(curl -sS -o "$resp" -w "%{http_code}" \
  --request POST \
  --url "https://${API_URL}/api/v1/clusters/${CLUSTER_ID}/sql-users" \
  --header "Authorization: Bearer ${TOKEN}" \
  --header "Cc-Version: 2024-09-16" \
  --header "Content-Type: application/json" \
  --data @"$BODY_FILE")

if [[ "$code" == "201" || "$code" == "200" ]]; then
  echo "User created."
  rm -f "$resp"
  exit 0
elif [[ "$code" == "409" ]]; then
  echo "User already exists."
  rm -f "$resp"
  exit 0
else
  echo "Create user failed with HTTP $code:"
  cat "$resp"
  rm -f "$resp"
  exit 1
fi
