# devstats-docker-lf

DevStats deployment using docker and managed AuroraDB and ElasticSearch


# Usage

# Devstats image

- Use `./docker/docker_build.sh` to build `devstats-lfda` docker image.
- Use `./docker/docker_bash.sh` to bash into `devstats-lfda` docker container.
- Use `./docker/docker_publish.sh` to publish `devstats-lfda` image to the dockerhub.
- Use `./docker/docker_remove.sh` to remove `devstats-lfda` docker image.
- Use `./docker/docker_cleanup.sh` to remove all containers and do `docker system prune`.
- Use `./docker/docker_remove_mapped_data.sh` to remove all data from directories shared between the host and containers.

# ElasticSearch

- Use `./docker/docker_es.sh` to start dockerized ElasticSearch 6.5.1 instance.
- Use `./docker/docker_es_bash.sh` to bash into the ElasticSearch container.
- Use `./docker/docker_es_indexes.sh` to see ES indexes.
- Use `./docker/docker_es_types.sh index` to see given index types.
- Use `./docker/docker_es_values.sh index` to see given index types.
- Use `./docker/docker_es_dump.sh indexname filename` to dump ES index into a file.
- Use `./docker/docker_es_restore.sh indexname filename` to restore ES index from a file.
- Use `./docker/docker_es_query.sh index type query` to query ES instance (allows quick lucene queries).
- Use `./docker/docker_es_search.sh index type query` to search ES instance (allows full query search JSON syntax).
- Use `./docker/docker_es_logs.sh` to see ES logs.
- Use `./docker/docker_es_health.sh` to do a health check (after succesfull deployment). It will display some inmdex structures and do some basic queries.
- Use `./docker/docker_remove_es.sh` to remove dockerized postgres instance.
- Use `./docker/docker_es_wait.sh` to wait for the ES docker container become ready.


# Postgres and deployment

- Use `PG_PASS=... ./docker/docker_psql.sh` to start dockerized postgres:11 instance.
- Use `PG_PASS=... ./docker/docker_psql_bash.sh` to bash into the Postgres container.
- To deploy from the container use `` GHA2DB_GITHUB_OAUTH="`cat /etc/github/oauths`" PG_PASS=... PG_PASS_RO=... PG_PASS_TEAM=... ./docker/docker_deploy_from_container.sh ``.
- It will deploy few Linux Foundation Networking projects into the dockerized postgres.
- It will use `./docker/docker_deploy_all.sh` script which currently uses `SKIPGRAFANA=1` and `NOBACKUP=1`.
- Use `PG_PASS=... ./docker/docker_psql_into_logs_db.sh` to connect to dockerized postgres host post 65432 -> container port 5432.
- Use `PG_PASS=... ./docker/docker_display_logs.sh` to see deployment logs.
- Use `PG_PASS=... ./docker/docker_health.sh` to do a health check (after succesfull deployment). It will display number of texts in the database.
- Use `./docker/docker_remove_psql.sh` to remove dockerized postgres instance.
- Use `PG_PASS=... ./docker/docker_psql_wait.sh` to wait for the postgres docker container become ready.


# Devstats hourly sync

- Use `` GHA2DB_GITHUB_OAUTH="`cat /etc/github/oauths`" PG_PASS=... ./docker/docker_devstats.sh `` to do devstats sync. This should be run hourly, ideally when new GHA files are available which is about every hour:08.


# DockerHub

- Devstats image can be pulled from the [docker hub](https://hub.docker.com/r/lukaszgryglicki/devstats-lfda/).


# One command test all

- Use `PASS=... ./docker/docker_test_all.sh` to test full deployment from the container. It will try to use `/etc/github/oauths` or `/etc/github/oauth` as a GitHub OAuth token (if file is present, otherwise it will use public mode - very restricted).
- Or specify GitHub OAuth token manually `GHA2DB_GITHUB_OAUTH=... PASS=... ./docker/docker_test_all.sh` to test full deployment from the container.
- Final command on a fresh system should be `clear; GHA2DB_GITHUB_OAUTH=key PASS=test ./docker/docker_test_all.sh`.
- To use aurora postgres database `clear; GHA2DB_GITHUB_OAUTH=key PASS=test AURORA=1 ./docker/docker_test_all.sh`.


# Vagrant

You can use vagrant for deployment, use scripts from `./vagrant` directory.

To test everything use `./deploy.sh` script. Prepend with `VAGRANT=1` or `DOCKER=1`.
