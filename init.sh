#!/bin/bash
set -e

# Create the extensions in the database
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS postgis;
    CREATE EXTENSION IF NOT EXISTS postgis_raster;
EOSQL

# Restore the database from the custom-format dump
pg_restore -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v "/docker-entrypoint-initdb.d/dump.backup"
