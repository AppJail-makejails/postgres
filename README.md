# PostgreSQL

PostgreSQL is a powerful, open source object-relational database system that uses and extends the SQL language combined with many features that safely store and scale the most complicated data workloads. The origins of PostgreSQL date back to 1986 as part of the POSTGRES project at the University of California at Berkeley and has more than 35 years of active development on the core platform.

PostgreSQL has earned a strong reputation for its proven architecture, reliability, data integrity, robust feature set, extensibility, and the dedication of the open source community behind the software to consistently deliver performant and innovative solutions. PostgreSQL runs on all major operating systems, has been ACID-compliant since 2001, and has powerful add-ons such as the popular PostGIS geospatial database extender. It is no surprise that PostgreSQL has become the open source relational database of choice for many people and organisations.

wikipedia.org/wiki/PostgreSQL

<img src="https://raw.githubusercontent.com/docker-library/docs/01c12653951b2fe592c1f93a13b4e289ada0e3a1/postgres/logo.png" width="30%" height="auto" alt="PostgreSQL logo">

## How to use this Makejail

### start a postgres instance

```console
$ appjail oci run -Pd \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    -o template=template.conf \
    -e POSTGRES_PASSWORD=mysecretpassword \
    ghcr.io/appjail-makejails/postgres some-postgres
```

The default `postgres` user and database are created in the entrypoint with `initdb`.

> The postgres database is a default database meant for use by users, utilities and third party applications.
>
> [postgresql.org/docs](https://www.postgresql.org/docs/14/app-initdb.html)

Please note that PostgreSQL requires the `sysvmsg`, `sysvsem`, and `sysvshm` parameters to be set to `new`, so you must use a custom template like the following:

**template.conf**:

```
exec.start: "/bin/sh /etc/rc"
exec.stop: "/bin/sh /etc/rc.shutdown jail"
mount.devfs
persist
sysvmsg: new
sysvsem: new
sysvshm: new
```

### ... or via `psql`

```console
$ appjail oci run \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    -o ephemeral \
    -o template=template.conf \
    ghcr.io/appjail-makejails/postgres postgres-cli \
    psql -h some-postgres -U postgres
psql (18.4)
Type "help" for help.

postgres=# SELECT 1;
 ?column?
----------
        1
(1 row)
```

### ... via [`appjail-director`](https://github.com/DtxdF/director)

```yaml
# Use postgres/example user/password credentials

options:
  - virtualnet: ':<random> default'
  - nat:

services:
  db:
    makejail: gh+AppJail-makejails/postgres
    options:
      - template: !ENV '${PWD}/template.conf'
      - container: 'boot args:--pull'
    oci:
      environment:
        - POSTGRES_PASSWORD: example
```

### How to extend this image

There are many ways to extend the `postgres` image. Without trying to support every possible use case, here are just a few that we have found useful.

#### Environment Variables

The PostgreSQL image uses several environment variables which are easy to miss. The only variable required is `POSTGRES_PASSWORD`, the rest are optional.

**Warning**: the OCI specific variables will only have an effect if you start the container with a data directory that is empty; any pre-existing database will be left untouched on container startup.

##### `POSTGRES_PASSWORD`

This environment variable is required for you to use the PostgreSQL image. It must not be empty or undefined. This environment variable sets the superuser password for PostgreSQL. The default superuser is defined by the `POSTGRES_USER` environment variable.

**Note 1**: The PostgreSQL image sets up `trust` authentication locally so you may notice a password is not required when connecting from `localhost` (inside the same container). However, a password will be required if connecting from a different host/container.

**Note 2**: This variable defines the superuser password in the PostgreSQL instance, as set by the `initdb` script during initial container startup. It has no effect on the `PGPASSWORD` environment variable that may be used by the psql client at runtime, as described at https://www.postgresql.org/docs/14/libpq-envars.html. `PGPASSWORD`, if used, will be specified as a separate environment variable.

##### `POSTGRES_USER`

This optional environment variable is used in conjunction with `POSTGRES_PASSWORD` to set a user and its password. This variable will create the specified user with superuser power and a database with the same name. If it is not specified, then the default user of `postgres` will be used.

Be aware that if this parameter is specified, PostgreSQL will still show `The files belonging to this database system will be owned by user "noroot"` during initialization. This refers to the FreeBSD system user (from `/etc/passwd` in the image) that the `postgres` daemon runs as, and as such is unrelated to the `POSTGRES_USER` option.

##### `POSTGRES_DB`

This optional environment variable can be used to define a different name for the default database that is created when the image is first started. If it is not specified, then the value of `POSTGRES_USER` will be used.

##### `POSTGRES_INITDB_ARGS`

This optional environment variable can be used to send arguments to `postgres initdb`. The value is a space separated string of arguments as `postgres initdb` would expect them. This is useful for adding functionality like data page checksums: `-e POSTGRES_INITDB_ARGS="--data-checksums"`.

##### `POSTGRES_INITDB_WALDIR`

This optional environment variable can be used to define another location for the Postgres transaction log. By default the transaction log is stored in a subdirectory of the main Postgres data folder (`PGDATA`). Sometimes it can be desireable to store the transaction log in a different directory which may be backed by storage with different performance or reliability characteristics.

**Note**: on PostgreSQL 9.x, this variable is `POSTGRES_INITDB_XLOGDIR` (reflecting [the changed name of the `--xlogdir` flag to `--waldir` in PostgreSQL 10+](https://wiki.postgresql.org/wiki/New_in_postgres_10#Renaming_of_.22xlog.22_to_.22wal.22_Globally_.28and_location.2Flsn.29)).

##### `POSTGRES_HOST_AUTH_METHOD`

This optional variable can be used to control the `auth-method` for `host` connections for `all` databases, `all` users, and `all` addresses. If unspecified then [`scram-sha-256` password authentication](https://www.postgresql.org/docs/14/auth-password.html) is used (in 14+; `md5` in older releases). On an uninitialized database, this will populate `pg_hba.conf` via this approximate line:

```console
echo "host all all all $POSTGRES_HOST_AUTH_METHOD" >> pg_hba.conf
```

See the PostgreSQL documentation on [`pg_hba.conf`](https://www.postgresql.org/docs/14/auth-pg-hba-conf.html) for more information about possible values and their meanings.

**Note 1**: It is not recommended to use `trust` since it allows anyone to connect without a password, even if one is set (like via `POSTGRES_PASSWORD`). For more information see the PostgreSQL documentation on [*Trust Authentication*](https://www.postgresql.org/docs/14/auth-trust.html).

**Note 2**: If you set `POSTGRES_HOST_AUTH_METHOD` to `trust`, then `POSTGRES_PASSWORD` is not required.

**Note 3**: If you set this to an alternative value (such as `scram-sha-256`), you might need additional `POSTGRES_INITDB_ARGS` for the database to initialize correctly (such as `POSTGRES_INITDB_ARGS=--auth-host=scram-sha-256`).

##### `PGDATA`

This (`PGDATA`) is an environment variable that is not AppJail specific. Because the variable is used by the `postgres` server binary (see the [PostgreSQL docs](https://www.postgresql.org/docs/14/app-postgres.html#id-1.9.5.14.7)), the entrypoint script takes it into account.

#### Secrets

As an alternative to passing sensitive information via environment variables, `_FILE` may be appended to some of the previously listed environment variables, causing the initialization script to load the values for those variables from files present in the container. In particular, this can be used to load passwords from files stored anywhere within the container. For example:

```console
$ mkdir -p /path/to/your/postgres/secrets
$ echo "mysecretpassword" > /path/to/your/postgres/secrets/passwd
$ appjail oci run -Pd \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    -o template=template.conf \
    -o volume="postgres-secrets" \
    -o fstab="/path/to/your/postgres/secrets postgres-secrets <volumefs> ro" \
    -e POSTGRES_PASSWORD_FILE="/volumes/postgres-secrets/passwd" \
    ghcr.io/appjail-makejails/postgres postgres
```

Currently, this is only supported for `POSTGRES_INITDB_ARGS`, `POSTGRES_PASSWORD`, `POSTGRES_USER`, and `POSTGRES_DB`.

#### Initialization scripts

If you would like to do additional initialization in an image derived from this one, add one or more `*.sql`, `*.sql.gz`, or `*.sh` scripts under `/entrypoint-initdb.d` (creating the directory if necessary). After the entrypoint calls `initdb` to create the default `postgres` user and database, it will run any `*.sql` files, run any executable `*.sh` scripts, and source any non-executable `*.sh` scripts found in that directory to do further initialization before starting the service.

**Warning**: scripts in `/entrypoint-initdb.d` are only run if you start the container with a data directory that is empty; any pre-existing database will be left untouched on container startup. One common problem is that if one of your `/entrypoint-initdb.d` scripts fails (which will cause the entrypoint script to exit) and your orchestrator restarts the container with the already initialized data directory, it will not continue on with your scripts.

For example, to add an additional user and database, add the following to `/entrypoint-initdb.d/init-user-db.sh`:

```bash
#!/usr/bin/env bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER appjail;
	CREATE DATABASE appjail;
	GRANT ALL PRIVILEGES ON DATABASE appjail TO appjail;
EOSQL
```

These initialization files will be executed in sorted name order as defined by the current locale. Any `*.sql` files will be executed by `POSTGRES_USER`, which defaults to the `postgres` superuser. It is recommended that any `psql` commands that are run inside of a `*.sh` script be executed as `POSTGRES_USER` by using the `--username "$POSTGRES_USER"` flag. This user will be able to connect without a password due to the presence of `trust` authentication for Unix socket connections made inside the container.

Additionally, these initialization scripts are run as the `noroot` user. Also, as of [docker-library/postgres#440](https://github.com/docker-library/postgres/pull/440), the temporary daemon started for these initialization scripts listens only on the Unix socket, so any `psql` usage should drop the hostname portion (see [docker-library/postgres#474 (comment)](https://github.com/docker-library/postgres/issues/474#issuecomment-416914741) for example).

Although you can use the `-u` parameter with `appjail oci run` to change the user to an arbitrary one, this image is designed to assign arbitrary UIDs and GIDs using the PUID and PGID environment variables. That is why `noroot` is used, and no other user can be used.

#### Database Configuration

There are many ways to set PostgreSQL server configuration. For information on what is available to configure, see the [PostgreSQL docs](https://www.postgresql.org/docs/14/runtime-config.html) for the specific version of PostgreSQL that you are running. Here are a few options for setting configuration:

-	Use a custom config file. Create a config file and get it into the container. If you need a starting place for your config file you can use the sample provided by PostgreSQL which is available in the container at `/usr/local/share/postgresql/postgresql.conf.sample`.

	-	**Important note:** you must set `listen_addresses = '*'`so that other containers will be able to access postgres.

	```console
	$ # get the default config
	$ appjail oci run \
        -o overwrite=force \
        -o virtualnet=":<random> default" -o nat \
        -o ephemeral \
        -o template=template.conf \
        ghcr.io/appjail-makejails/postgres postgres-config \
        cat /dev/null
    $ appjail oci exec postgres-config \
        cat /usr/local/share/postgresql/postgresql.conf.sample > my-postgres.conf
    $ appjail stop postgres-config

	$ # customize the config

	$ # run postgres with custom config
	$ appjail oci run -Pd \
        -o overwrite=force \
        -o virtualnet=":<random> default" \
        -o nat \
        -o template=template.conf \
        -o fstab="$PWD/my-postgres.conf postgresql.conf nullfs ro" \
        -e POSTGRES_PASSWORD=mysecretpassword \
        ghcr.io/appjail-makejails/postgres some-postgres \
        postgres -c 'config_file=/postgresql.conf'
	```

-	Set options directly on the run line. The entrypoint script is made so that any options passed to the appjail command will be passed along to the `postgres` server daemon. From the [PostgreSQL docs](https://www.postgresql.org/docs/14/app-postgres.html) we see that any option available in a `.conf` file can be set via `-c`.

	```console
    $ appjail oci run -Pd \
        -o overwrite=force \
        -o virtualnet=":<random> default" \
        -o nat \
        -o template=template.conf \
        -e POSTGRES_PASSWORD=mysecretpassword \
        ghcr.io/appjail-makejails/postgres some-postgres \
        postgres -c shared_buffers=256MB -c max_connections=200
	```

#### Locale Customization

The `FreeBSD-locales` package is included in this image, and `LC_ALL` is set to `C.UTF-8` by default. If you change this environment variable to, for example, `es_ES.UTF-8`, the cluster will initialize based on this setting.

### Caveats

If there is no database when `postgres` starts in a container, then `postgres` will create the default database for you. While this is the expected behavior of `postgres`, this means that it will not accept incoming connections during that time. This may cause issues when using automation tools, such as `appjail-director`, that start several containers simultaneously.

#### Where to Store Data

1.	Create a data directory on a suitable volume on your host system, e.g. `/my/own/datadir`.
2.	Start your `postgres` container like this:

	```console
	$ appjail oci run -Pd \
        -o overwrite=force \
        -o virtualnet=":<random> default" \
        -o nat \
        -o template=template.conf \
        -o fstab="/my/own/datadir /var/db/postgres" \
        -e POSTGRES_PASSWORD=mysecretpassword \
        ghcr.io/appjail-makejails/postgres:15.1-14 some-postgres
	```

The `-o fstab="/my/own/datadir /var/db/postgres"` part of the command mounts the `/my/own/datadir` directory from the underlying host system as `/var/db/postgres` inside the container, where PostgreSQL by default will write its data files.

### Arguments (stage: build)

* `postgres_from` (default: `ghcr.io/appjail-makejails/postgres`): Location of OCI image. See also [OCI Configuration](#oci-configuration).
* `postgres_tag` (default: `latest`): OCI image tag. See also [OCI Configuration](#oci-configuration).

### Environment (OCI image)

* `PGID` (default: `1000`): Equivalent to `PUID` but for the Process Group ID.
* `PUID` (default: `1000`): Process User ID for the container's main process, allowing you to match the owner of files written to mounted host volumes to your host system's user. Writable volumes are changed based on this environment variable.

### Volumes

| Name | Owner | Group | Perm | Type | Mountpoint |
| --- | --- | --- | --- | --- | --- |
| appjail-ef4187646f-var_db_postgres | `${PUID}` | `${PGID}` | - | - | /var/db/postgres |

## OCI Configuration

```yaml
build:
  variants:
    - tag: 15.1-14
      containerfile: Containerfile
      args:
        FREEBSD_RELEASE: "15.1"
        POSTGRESVER: "14"
        NO_PKGCLEAN: "1"
      cache_dirs: ["pkgcache0:/var/cache/pkg"]
    - tag: 15.1-15
      containerfile: Containerfile
      args:
        FREEBSD_RELEASE: "15.1"
        POSTGRESVER: "15"
        NO_PKGCLEAN: "1"
      cache_dirs: ["pkgcache0:/var/cache/pkg"]
    - tag: 15.1-16
      containerfile: Containerfile
      args:
        FREEBSD_RELEASE: "15.1"
        POSTGRESVER: "16"
        NO_PKGCLEAN: "1"
      cache_dirs: ["pkgcache0:/var/cache/pkg"]
    - tag: 15.1-17
      containerfile: Containerfile
      args:
        FREEBSD_RELEASE: "15.1"
        POSTGRESVER: "17"
        NO_PKGCLEAN: "1"
      cache_dirs: ["pkgcache0:/var/cache/pkg"]
    - tag: 15.1-18
      containerfile: Containerfile
      aliases: ["latest"]
      default: true
      args:
        FREEBSD_RELEASE: "15.1"
        POSTGRESVER: "18"
        NO_PKGCLEAN: "1"
      cache_dirs: ["pkgcache0:/var/cache/pkg"]
```

## Notes

1. The ideas present in the Docker image of PostgreSQL are taken into account for users who are familiar with it.
