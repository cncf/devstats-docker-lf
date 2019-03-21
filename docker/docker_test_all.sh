#!/bin/bash
# AURORA=1 - use Aurora DB
# RESTART=1 - reuse existing deployment
if [ -z "${PASS}" ]
then
  echo "$0: Set the password via PASS=... $*"
  exit 1
fi

if [ -z "${GHA2DB_GITHUB_OAUTH}" ]
then
  GITHUB_OAUTH_FILE="/etc/github/oauths"
  if [ ! -f "${GITHUB_OAUTH_FILE}" ]
  then
    echo "Warning: no ${GITHUB_OAUTH_FILE} file, trying another file"
    GITHUB_OAUTH_FILE="/etc/github/oauth"
    if [ ! -f "${GITHUB_OAUTH_FILE}" ]
    then
      echo "Warning: no ${GITHUB_OAUTH_FILE} file, setting env variables to skip GitHub API"
      export GHA2DB_GHAPISKIP=1
    else
      echo "GitHub API credentials found (${GITHUB_OAUTH_FILE}), using them"
      export GHA2DB_GITHUB_OAUTH="`cat ${GITHUB_OAUTH_FILE}`"
    fi
  else
    echo "GitHub API credentials found (${GITHUB_OAUTH_FILE}), using them"
    export GHA2DB_GITHUB_OAUTH="`cat ${GITHUB_OAUTH_FILE}`"
  fi
else
  echo "GitHub API credentials provided from the env variable, using them"
  export GHA2DB_GITHUB_OAUTH
fi

./cron/sysctl_config.sh
if [ -z "${RESTART}" ]
then
  ./docker/docker_remove.sh
  ./docker/docker_remove_es.sh
  if [ -z "$AURORA" ]
  then
    ./docker/docker_remove_psql.sh
  fi
  ./docker/docker_es.sh || exit 3
  if [ -z "$AURORA" ]
  then
    PG_PASS="${PASS}" ./docker/docker_psql.sh || exit 4
  fi
fi
./docker/docker_build.sh || exit 5
./docker/docker_es_wait.sh
PG_PASS="${PASS}" ./docker/docker_psql_wait.sh
PG_PASS="${PASS}" PG_PASS_RO="${PASS}" PG_PASS_TEAM="${PASS}" ./docker/docker_deploy_from_container.sh || exit 7
PG_PASS="${PASS}" ./docker/docker_display_logs.sh || exit 8
PG_PASS="${PASS}" ./docker/docker_devstats.sh || exit 9
PG_PASS="${PASS}" ./docker/docker_display_logs.sh || exit 10
./docker/docker_es_logs.sh || exit 11
./docker/docker_es_indexes.sh || exit 12
./docker/docker_es_health.sh || exit 13
PG_PASS="${PASS}" ./docker/docker_health.sh || exit 14
echo 'All OK'
echo 'You can call "./docker/docker_remove_mapped_data.sh" and/or "./docker/docker_cleanup.sh" to clean up data'
