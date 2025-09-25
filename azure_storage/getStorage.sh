#!/usr/bin/env bash
set -euo pipefail

# 1) Grab the raw account key
RAW_KEY="$(az storage account keys list \
  --resource-group jphaugla-crdb-rg \
  --account-name jphauglacrdbsa2 \
  --query '[0].value' -o tsv)"

echo "RAW_KEY is:"
printf '%s\n' "$RAW_KEY"

# 2) URL-encode it (so +, /, = are safe in a URI)
ENC_KEY="$(python3 -c "import urllib.parse; print(urllib.parse.quote_plus('$RAW_KEY'))")"

echo "ENC_KEY is:"
printf '%s\n' "$ENC_KEY"

