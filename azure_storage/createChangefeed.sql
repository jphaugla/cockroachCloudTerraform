CREATE CHANGEFEED FOR TABLE defaultdb.public."transaction"
INTO 'external://azure_cdc'
WITH
  envelope='wrapped',
  diff,
  format='json',
  resolved='15s';
