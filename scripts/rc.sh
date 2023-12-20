#!/bin/sh

set -e

# Environment:
# - PGDATA

. /scripts/default.conf
. /scripts/lib.subr

info "Enabling postgresql ..."
sysrc postgresql_enable="YES"

info "Configuring 'postgresql_data' ..."
sysrc postgresql_data="${PGDATA:-${DEFAULT_PGDATA}}"

info "Setting \"listen_addresses = '*'\" ..."
sed -i '' -Ee "s/^#?listen_addresses[[:space:]]*=[[:space:]][\"'][^\"']*[\"'](.+)/listen_addresses = '*'\1/" "${PGDATA:-${DEFAULT_PGDATA}}/postgresql.conf"

info "Starting postgresql ..."
service postgresql start
