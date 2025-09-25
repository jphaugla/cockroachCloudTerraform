# set creds once (raw account key, not URL-encoded)
export AZURE_STORAGE_ACCOUNT=jphauglblahbsa2
#   even having AZURE_STORAGE_KEY is causing issues in the git push
export AZxxURE_STxxAGE_KEY=''

BLOB='cdc/2025-09-25/blahblah1848430blahblah0000blahblahcaf287129fbf78c-1-1-00000000-transaction-1.ndjson'
TMP="$(mktemp)"

az storage blob download \
  --container-name app-uploads \
  --name "$BLOB" \
  --file "$TMP" \
  --no-progress >/dev/null

# View first lines; pretty-print one line with jq if you like
head -n 5 "$TMP" | jq -c .
rm -f "$TMP"
