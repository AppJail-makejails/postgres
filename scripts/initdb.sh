#!/bin/sh

set -e

# Environment:
# - POSTGRES_PASSWORD (optional if POSTGRES_HOST_AUTH_METHOD is trust)
# - POSTGRES_USER
# - POSTGRES_INITDB_ARGS (optional)
# - POSTGRES_HOST_AUTH_METHOD (optional)
# - PGDATA

. /scripts/default.conf
. /scripts/lib.subr

if [ -z "${POSTGRES_PASSWORD}" ] && [ "${POSTGRES_HOST_AUTH_METHOD}" != "trust" ]; then
	err "The database is not initialized and the superuser password has not been specified."
	err "You should specify \"-V POSTGRES_PASSWORD\" to a non-empty value or alternatively"
	err "you can set POSTGRES_HOST_AUTH_METHOD=trust, but the latter is *not* recommended."
	exit 1
fi

if [ "${POSTGRES_HOST_AUTH_METHOD}" = "trust" ]; then
	warn "POSTGRES_HOST_AUTH_METHOD has been set to \"trust\". This will allow anyone with"
	warn "access to your postgres instance without a password even if POSTGRES_PASSWORD is set."
	warn "See https://www.postgresql.org/docs/current/auth-trust.html"
	warn "---"
	warn "It is not recommended to use POSTGRES_HOST_AUTH_METHOD=trust. Replace it with"
	warn "\"-V POSTGRES_PASSWORD=password\" instead to set a password in \"appjail makejail\"."
fi

pwfile=
if [ -n "${POSTGRES_PASSWORD}" ]; then
	pwfile=`mktemp -t postgres`

	printf "%s\n" "${POSTGRES_PASSWORD}" > "${pwfile}"

	POSTGRES_INITDB_ARGS="${POSTGRES_INITDB_ARGS} --pwfile=${pwfile}"
fi

eval initdb \
	--pgdata "${PGDATA:-${DEFAULT_PGDATA}}" \
	--user "${POSTGRES_USER:-${DEFAULT_POSTGRES_USER}}" \
	${POSTGRES_INITDB_ARGS}

if [ -n "${pwfile}" ]; then
	rm -f "${pwfile}"
fi
