#!/bin/sh

set -e

# Environment:
# - POSTGRES_HOST_AUTH_METHOD
# - PGDATA

. /scripts/default.conf
. /scripts/lib.subr

if [ -z "${POSTGRES_HOST_AUTH_METHOD}" ]; then
	POSTGRES_HOST_AUTH_METHOD=`postgres -C password_encryption -D "${PGDATA:-${DEFAULT_PGDATA}}"`
fi

printf "host all all all %s\n" "${POSTGRES_HOST_AUTH_METHOD}" >> "${PGDATA:-${DEFAULT_PGDATA}}/pg_hba.conf"
