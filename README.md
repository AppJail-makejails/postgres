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
    -o virtualnet=":<random> nat" \
    -o nat \
    -o template=template.conf \
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

```

## Locale Customization

### Initialization scripts

### Arguments

* `postgres_tag` (default: `13.2-16`): See [#tags](#tags).

### Environment

* `POSTGRES_PASSWORD`: 
* `POSTGRES_USER` (default: `postgres`): 
* `POSTGRES_INITDB_ARGS` (optional)
* `POSTGRES_HOST_AUTH_METHOD`: 
* `PGDATA`
* `POSTGRES_DB` (default: `$POSTGRES_USER`): 

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
| `14.0-12` | `amd64` | `13.2-RELEASE` | `thin` |     `12`     |
| `14.0-13` | `amd64` | `13.2-RELEASE` | `thin` |     `13`     |
| `14.0-14` | `amd64` | `13.2-RELEASE` | `thin` |     `14`     |
| `14.0-15` | `amd64` | `13.2-RELEASE` | `thin` |     `15`     |
| `14.0-16` | `amd64` | `13.2-RELEASE` | `thin` |     `16`     |

## Notes

1. The ideas present in the Docker image of PostgreSQL are taken into account for users who are familiar with it.
2. `listen_addresses` is set to `*`.
