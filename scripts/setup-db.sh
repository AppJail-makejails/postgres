#!/bin/sh

set -e

# Environment:
# - POSTGRES_USER
# - POSTGRES_DB

. /scripts/default.conf
. /scripts/lib.subr

POSTGRES_USER="${POSTGRES_USER:-${DEFAULT_POSTGRES_USER}}"

DB_ALREADY_EXISTS=`echo "SELECT 1 FROM pg_database WHERE datname = :'db';" | POSTGRES_DB= /scripts/process-sql.sh --dbname=postgres --set db="${POSTGRES_DB:-${POSTGRES_USER}}" --tuples-only`

if [ -z "${DB_ALREADY_EXISTS}" ]; then
	info "Creating database '${POSTGRES_DB:-${POSTGRES_USER}}'"
	echo 'CREATE DATABASE :"db";' | POSTGRES_DB= /scripts/process-sql.sh --dbname=postgres --set db="${POSTGRES_DB:-${POSTGRES_USER}}" 
else
	info "Database '${POSTGRES_DB:-${POSTGRES_USER}}' already exists."
fi
