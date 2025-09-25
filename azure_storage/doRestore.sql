RESTORE DATABASE defaultdb
FROM LATEST IN 'external://azure_cdc'
WITH new_db_name = 'restored_defaultdb';
