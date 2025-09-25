# set creds once (raw account key, not URL-encoded)
export AZURE_STORAGE_ACCOUNT=jphauglblahbsa2
export AZURE_STORAGE_KEY='dckJblah+gRsNblahshiETrzxGkbLxGO9WmWIgzz2ncFM2blahblahzblahS1Yb9g=='

BLOB='cdc/2025-09-25/202509251848430057739660000000000-ccaf287129fbf78c-1-1-00000000-transaction-1.ndjson'
TMP="$(mktemp)"

az storage blob download \
  --container-name app-uploads \
  --name "$BLOB" \
  --file "$TMP" \
  --no-progress >/dev/null

# View first lines; pretty-print one line with jq if you like
head -n 5 "$TMP" | jq -c .
rm -f "$TMP"
