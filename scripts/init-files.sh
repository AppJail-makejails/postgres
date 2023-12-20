#!/bin/sh

set -e

if [ ! -d "/appjail-initdb.d" ]; then
	exit 0
fi

ls /appjail-initdb.d/* > /dev/null 2>&1

. /scripts/lib.subr

for file in /appjail-initdb.d/*; do
	case "${file}" in
		*.sh)
			if [ -x "${file}" ]; then
				info "Running ${file}"
				"${file}"
			else
				info "Sourcing ${file}"
				. "${file}"
			fi
			;;
		*.sql) info "Processing ${file}"; /scripts/process-sql.sh < "${file}" ;;
		*.sql.bz|*.sql.bz2) info "Processing ${file}"; bzcat "${file}" | /scripts/process-sql.sh ;;
		*.sql.gz) info "Processing ${file}"; gzcat "${file}" | /scripts/process-sql.sh ;;
		*.sql.xz) info "Processing ${file}"; xzcat "${file}" | /scripts/process-sql.sh ;;
		*.sql.zst) info "Processing ${file}"; zstdcat "${file}" | /scripts/process-sql.sh ;;
		*) warn "Ignoring ${file}" ;;
	esac
done
