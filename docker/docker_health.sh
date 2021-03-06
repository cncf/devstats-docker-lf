#!/bin/bash
# AURORA=1 - use Aurora DB
echo 'Uses devstats runq command to connect to host postgres and display number of texts in the database'
if [ -z "$PG_PASS" ]
then
  if [ -z "$INTERACTIVE" ]
  then
    echo "$0: you need to set PG_PASS=... environment variable"
    exit 1
  else
    echo -n 'Postgres pwd: '
    read -s PG_PASS
    echo ''
  fi
fi

export TEST_SERVER=1
export LIST_FN_PREFIX="docker/all_"

host=`docker run devstats-lfda ip route show 2>/dev/null | awk '/default/ {print $3}'`

. ./devel/all_dbs.sh || exit 2
for db in $all
do
  echo "Database: $db"
  if [ -z "$AURORA" ]
  then
    docker run -e GHA2DB_SKIPTIME=1 -e GHA2DB_SKIPLOG=1 -e PG_PORT=65432 -e PG_HOST="${host}" -e PG_PASS="${PG_PASS}" -e PG_DB="${db}" --env-file <(env | grep GHA2DB) devstats-lfda runq util_sql/num_texts.sql || exit 3
  else
    docker run -e GHA2DB_SKIPTIME=1 -e GHA2DB_SKIPLOG=1 -e PG_PORT=5432 -e PG_HOST="dev-analytics-api-devstats-dev.cluster-czqvov18pw9a.us-west-2.rds.amazonaws.com" -e PG_PASS="${PG_PASS}" -e PG_DB="${db}" --env-file <(env | grep GHA2DB) devstats-lfda runq util_sql/num_texts.sql || exit 3
  fi
done

user=gha_admin
if [ ! -z "${PG_USER}" ]
then
  user="${PG_USER}"
fi
  
if [ -z "$AURORA" ]
then
  docker run -e PG_PORT=65432 -e PG_HOST="${host}" -e PG_PASS="${PG_PASS}" devstats-lfda db.sh psql lfn -c 'select * from sannotations_shared limit 10' || exit 4
else
  docker run -e PG_USER="${user}" -e PG_PORT=5432 -e PG_HOST="dev-analytics-api-devstats-dev.cluster-czqvov18pw9a.us-west-2.rds.amazonaws.com" -e PG_PASS="${PG_PASS}" devstats-lfda db.sh psql lfn -c 'select * from sannotations_shared limit 10' || exit 4
fi
