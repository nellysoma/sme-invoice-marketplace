#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
  CREATE USER ${APP_DB_USER} WITH PASSWORD '${APP_DB_PASSWORD}';
EOSQL

for db in user_db invoice_db openbanking_db creditrisk_db financing_db bidding_db payment_db notification_db admin_db; do
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -c "CREATE DATABASE ${db} OWNER ${APP_DB_USER};"
done