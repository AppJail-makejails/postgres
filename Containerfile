ARG FREEBSD_RELEASE

FROM ghcr.io/appjail-makejails/core:${FREEBSD_RELEASE}

ARG POSTGRESVER
ARG NO_PKGCLEAN

LABEL org.opencontainers.image.title="PostgreSQL" \
    org.opencontainers.image.description="The World's Most Advanced Open Source Relational Database" \
    org.opencontainers.image.source="https://github.com/AppJail-makejails/postgres" \
    org.opencontainers.image.url="https://github.com/AppJail-makejails/postgres" \
    org.opencontainers.image.vendor="DtxdF" \
    org.opencontainers.image.authors="Jesús Daniel Colmenares Oviedo <dtxdf@disroot.org>"

RUN set -xe; \
    \
    pkg update; \
    pkg install postgresql${POSTGRESVER}-server \
        bash \
        gsed \
        FreeBSD-xz; \
    \
    if [ -z "${NO_PKGCLEAN}" ]; then \
        pkg clean -a; \
        rm -rf /var/cache/pkg/*; \
    fi; \
    rm -rf /var/db/pkg/repos/*; \
    \
	cp -v /usr/local/share/postgresql/postgresql.conf.sample /usr/local/share/postgresql/postgresql.conf.sample.orig; \
	gsed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/local/share/postgresql/postgresql.conf.sample; \
	grep -F "listen_addresses = '*'" /usr/local/share/postgresql/postgresql.conf.sample

ENV PGDATA /var/db/postgres/data${POSTGRESVER}
VOLUME ["/var/db/postgres"]

ENV LC_ALL C.UTF-8
COPY entrypoint.sh ensure-initdb.sh /
RUN ln -s /ensure-initdb.sh /enforce-initdb.sh && \
    chmod 555 /entrypoint.sh && \
    mkdir -p /entrypoint-initdb.d && \
    chmod 765 /entrypoint-initdb.d
ENTRYPOINT ["/entrypoint.sh"]

STOPSIGNAL SIGINT

EXPOSE 5432
CMD ["postgres"]
