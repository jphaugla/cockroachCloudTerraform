# deleteArecord.sh
az network private-dns record-set a delete \
  -g "$RG" -z "$CRDB_INTERNAL_DNS" -n "@" --yes --only-show-errors || true
