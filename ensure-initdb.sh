#!/usr/bin/env bash
set -Eeuo pipefail

#
# This script is intended for three main use cases:
#
#  1. (most importantly) as an example of how to use "entrypoint.sh" to extend/reuse the initialization behavior
#
#  2. ("ensure-initdb.sh") as a Kubernetes "init container" to ensure the provided database directory is initialized; see also "startup probes" for an alternative solution
#       (no-op if database is already initialized)
#
#  3. ("enforce-initdb.sh") as part of CI to ensure the database is fully initialized before use
#       (error if database is already initialized)
#

source /entrypoint.sh

# arguments to this script are assumed to be arguments to the "postgres" server (same as "entrypoint.sh"), and most "entrypoint.sh" functions assume "postgres" is the first argument (see "_main" over there)
if [ "$#" -eq 0 ] || [ "$1" != 'postgres' ]; then
	set -- postgres "$@"
fi

# see also "_main" in "entrypoint.sh"

create_user
docker_setup_env
# setup data directories and permissions (when run as root)
docker_create_db_directories
if [ "$(id -u)" != "${PUID}" ]; then
	# then restart script as postgres user
	exec su-exec noroot "$BASH_SOURCE" "$@"
fi

# only run initialization on an empty data directory
if [ -z "$DATABASE_ALREADY_EXISTS" ]; then
	docker_verify_minimum_env
	docker_error_old_databases

	# check dir permissions to reduce likelihood of half-initialized database
	ls /entrypoint-initdb.d/ > /dev/null

	docker_init_database_dir
	pg_setup_hba_conf "$@"

	# PGPASSWORD is required for psql when authentication is required for 'local' connections via pg_hba.conf and is otherwise harmless
	# e.g. when '--auth=md5' or '--auth-local=md5' is used in POSTGRES_INITDB_ARGS
	export PGPASSWORD="${PGPASSWORD:-$POSTGRES_PASSWORD}"
	docker_temp_server_start "$@"

	docker_setup_db
	docker_process_init_files /entrypoint-initdb.d/*

	docker_temp_server_stop
	unset PGPASSWORD
else
	self="$(basename "$0")"
	case "$self" in
		ensure-initdb.sh)
			echo >&2 "$self: note: database already initialized in '$PGDATA'!"
			exit 0
			;;

		enforce-initdb.sh)
			echo >&2 "$self: error: (unexpected) database found in '$PGDATA'!"
			exit 1
			;;

		*)
			echo >&2 "$self: error: unknown file name: $self"
			exit 99
			;;
	esac
fi
