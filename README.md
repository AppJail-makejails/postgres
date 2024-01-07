# PostgreSQL

PostgreSQL is a powerful, open source object-relational database system that uses and extends the SQL language combined with many features that safely store and scale the most complicated data workloads. The origins of PostgreSQL date back to 1986 as part of the POSTGRES project at the University of California at Berkeley and has more than 35 years of active development on the core platform.

PostgreSQL has earned a strong reputation for its proven architecture, reliability, data integrity, robust feature set, extensibility, and the dedication of the open source community behind the software to consistently deliver performant and innovative solutions. PostgreSQL runs on all major operating systems, has been ACID-compliant since 2001, and has powerful add-ons such as the popular PostGIS geospatial database extender. It is no surprise that PostgreSQL has become the open source relational database of choice for many people and organisations.

wikipedia.org/wiki/PostgreSQL

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Postgresql_elephant.svg/540px-Postgresql_elephant.svg.png" width="80%" height="auto">

## How to use this Makejail

### Standalone

```
# appjail makejail \
    -j postgres \
    -f gh+AppJail-makejails/postgres \
    -o virtualnet=":<random> default" \
    -o nat \
    -o template="$PWD/template.conf" \
    -V POSTGRES_PASSWORD=mysecretpassword
# appjail cmd jexec postgres -U postgres psql
$ psql
psql (16.0)
Type "help" for help.

postgres=# SELECT 1;
 ?column?
----------
        1
(1 row)
```

You need a template like the following:

**template.conf**:

```
exec.start: "/bin/sh /etc/rc"
exec.stop: "/bin/sh /etc/rc.shutdown jail"
sysvmsg: new
sysvsem: new
sysvshm: new
mount.devfs
```

### Deploy using appjail-director

**appjail-director.yml**:

```yaml
options:
  - virtualnet: ':<random> default'
  - nat:

services:
  db:
    name: postgres
    makejail: gh+AppJail-makejails/postgres
    environment:
      - POSTGRES_PASSWORD: example
    options:
      - template: !ENV '${PWD}/template.conf'

  adminerevo:
    name: adminerevo
    makejail: gh+AppJail-makejails/adminerevo
    options:
      - expose: '8080:80'
```

Run `appjail-director up` and wait until the project finishes. In just a few minutes you have PostgreSQL deployed.

### Locale Customization

For an existing jail, you can apply a Makejail as follows:

```
STAGE apply

CMD echo "postgres:\\" >> /etc/login.conf
CMD echo "        :lang=en_US.UTF-8:\\" >> /etc/login.conf
CMD echo "        :setenv=LC_COLLATE=C:\\" >> /etc/login.conf
CMD echo "        :tc=default:" >> /etc/login.conf

CMD cap_mkdb /etc/login.conf

SYSRC postgresql_class=postgres

SERVICE postgresql restart
```

Simply use `appjail apply`:

```
appjail apply postgres
```

### Initialization scripts

If you would like to do additional initialization in an image derived from this one, add one or more `*.sql`, `*.sql.gz`, or `*.sh` scripts under `/appjail-initdb.d` (creating the directory if necessary). After starting PostgreSQL, this Makejail will run any `*.sql` files, run any executable `*.sh` scripts, and source any non-executable `*.sh` scripts found in that directory for further customization.

For example, to add an additional user and database, add the following to `/appjail-initdb.d/init-user-db.sh`:

```sh
#!/bin/sh

set -e

psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" <<-EOSQL
        CREATE USER appjail;
        CREATE DATABASE appjail;
        GRANT ALL PRIVILEGES ON DATABASE appjail TO appjail;
EOSQL
```

These initialization files will be executed in lexicographical order. Any `*.sql` files will be executed by `POSTGRES_USER`, which defaults to the `postgres` superuser. It is recommended that any psql commands that are run inside of a `*.sh` script be executed as `POSTGRES_USER` by using the `--username "$POSTGRES_USER"` flag. This user will be able to connect without a password due to the presence of trust authentication for Unix socket connections made inside the container.

### Arguments

* `postgres_tag` (default: `13.2-16`): See [#tags](#tags).

### Environment

* `POSTGRES_PASSWORD`: This environment variable is required for you to use the PostgreSQL Makejail. It must not be empty or undefined. This environment variable sets the superuser password for PostgreSQL. The default superuser is defined by the `POSTGRES_USER` environment variable. This environment variable is optional when `POSTGRES_HOST_AUTH_METHOD` is `trust`.
* `POSTGRES_USER` (default: `postgres`): This optional environment variable is used in conjunction with `POSTGRES_PASSWORD` to set a user and its password. This variable will create the specified user with superuser power and a database with the same name. If it is not specified, then the default user of postgres will be used.
* `POSTGRES_INITDB_ARGS` (optional): This optional environment variable can be used to send arguments to `postgres initdb`. The value is a space separated string of arguments as `postgres initdb` would expect them. This is useful for adding functionality like data page checksums: `-V POSTGRES_INITDB_ARGS="--data-checksums"`.
* `POSTGRES_HOST_AUTH_METHOD`: This optional variable can be used to control the `auth-method` for `host` connections for `all` databases, `all` users, and `all` addresses. If unspecified then `scram-sha-256` password authentication is used (in 14+; `md5` in older releases).
* `PGDATA`: This optional variable can be used to define another location - like a subdirectory - for the database files. The default value is `/var/db/postgres/data${pg_version}` where `${pg_version}` is the PostgreSQL major version (e.g.: `/var/db/postgres/data16`). 
* `POSTGRES_DB` (default: `$POSTGRES_USER`): This optional environment variable can be used to define a different name for the default database that is created when the Makejail is first started. If it is not specified, then the value of `POSTGRES_USER` will be used.

### Volumes

#### All

| Name    | Owner | Group | Perm | Type | Mountpoint       |
| ------- | ----- | ----- | ---- | ---- | ---------------- |
| pg-db   |  770  |  770  |  -   |  -   | /var/db/postgres |
| pg-done |   -   |   -   |  -   |  -   | /.psql-done      |

#### PostgreSQL 12.x

| Name    | Owner | Group | Perm | Type | Mountpoint              |
| ------- | ----- | ----- | ---- | ---- | ----------------------- |
| pg-data |  770  |  770  | 700  |  -   | /var/db/postgres/data12 |

#### PostgreSQL 13.x

| Name    | Owner | Group | Perm | Type | Mountpoint              |
| ------- | ----- | ----- | ---- | ---- | ----------------------- |
| pg-data |  770  |  770  | 700  |  -   | /var/db/postgres/data13 |

#### PostgreSQL 14.x

| Name    | Owner | Group | Perm | Type | Mountpoint              |
| ------- | ----- | ----- | ---- | ---- | ----------------------- |
| pg-data |  770  |  770  | 700  |  -   | /var/db/postgres/data14 |

#### PostgreSQL 15.x

| Name    | Owner | Group | Perm | Type | Mountpoint              |
| ------- | ----- | ----- | ---- | ---- | ----------------------- |
| pg-data |  770  |  770  | 700  |  -   | /var/db/postgres/data15 |

#### PostgreSQL 16.x

| Name    | Owner | Group | Perm | Type | Mountpoint              |
| ------- | ----- | ----- | ---- | ---- | ----------------------- |
| pg-data |  770  |  770  | 700  |  -   | /var/db/postgres/data16 |

## Tags

| Tag       | Arch    | Version        | Type   | `pg_version` |
| --------- | ------- | -------------- | ------ | ------------ |
| `13.2-12` | `amd64` | `13.2-RELEASE` | `thin` |     `12`     |
| `13.2-13` | `amd64` | `13.2-RELEASE` | `thin` |     `13`     |
| `13.2-14` | `amd64` | `13.2-RELEASE` | `thin` |     `14`     |
| `13.2-15` | `amd64` | `13.2-RELEASE` | `thin` |     `15`     |
| `13.2-16` | `amd64` | `13.2-RELEASE` | `thin` |     `16`     |
| `14.0-12` | `amd64` | `14.0-RELEASE` | `thin` |     `12`     |
| `14.0-13` | `amd64` | `14.0-RELEASE` | `thin` |     `13`     |
| `14.0-14` | `amd64` | `14.0-RELEASE` | `thin` |     `14`     |
| `14.0-15` | `amd64` | `14.0-RELEASE` | `thin` |     `15`     |
| `14.0-16` | `amd64` | `14.0-RELEASE` | `thin` |     `16`     |

## Notes

1. The ideas present in the Docker image of PostgreSQL are taken into account for users who are familiar with it.
2. `listen_addresses` is set to `*`.
3. This Makejail assumes a new installation for each run, if you want to not run the scripts that configure PostgreSQL, mount an empty directory to `/.psql-done`.
