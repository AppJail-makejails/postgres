#!/bin/sh

# Environment:
# - POSTGRES_DB
# - POSTGRES_USER

. /scripts/default.conf

if [ -n "${POSTGRES_DB}" ]; then
	set -- "$@" --dbname="${POSTGRES_DB}"
fi

PGHOST= PGHOSTADDR= psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER:-${DEFAULT_POSTGRES_USER}}" --no-password --no-psqlrc "$@"
