#!/bin/sh

set -e

# Environment:
# - PGDATA

. /scripts/default.conf
. /scripts/lib.subr

if [ ! -d "${PGDATA:-${DEFAULT_PGDATA}}" ]; then
    err "The PostgreSQL data directory does not exist. The cause seems to be the use of a"
    err "different PostgreSQL major version than the one currently installed."
fi

info "Enabling postgresql ..."
sysrc postgresql_enable="YES"

info "Configuring 'postgresql_data' ..."
sysrc postgresql_data="${PGDATA:-${DEFAULT_PGDATA}}"

info "Setting \"listen_addresses = '*'\" ..."
sed -i '' -Ee "s/^#?listen_addresses[[:space:]]*=[[:space:]][\"'][^\"']*[\"'](.+)/listen_addresses = '*'\1/" "${PGDATA:-${DEFAULT_PGDATA}}/postgresql.conf"

info "Starting postgresql ..."
service postgresql start
