# restart instance
ssh nc2 "
  cd ~/docker/airflow && \
  docker compose --env-file ./config/.env down --volumes --remove-orphans \
    || docker compose down --volumes --remove-orphans \
    || true
  docker compose --env-file ./config/.env build
"

# # crate necessary folders & stop existing instance
ssh nc2 "\
  mkdir -p ~/docker/airflow && \
  rm -rf ~/docker/airflow/dags 2>/dev/null || true && \
  rm -rf ~/docker/airflow/plugins 2>/dev/null || true && \
  rm -rf ~/docker/airflow/config 2>/dev/null || true && \
  mkdir -p ~/docker/airflow/config && \
  mkdir -p ~/docker/airflow/dags && \
  mkdir -p ~/docker/airflow/plugins \
  mkdir -p ~/docker/airflow/logs && \
  # it is fine for the logs to fail chaning perms, 
  # this only really matters on init
  chmod -R 777 ~/docker/airflow/logs 2>/dev/null || true
"

# # copy over a couple files
rsync -avP * nc2:~/docker/airflow/

# restart instance
ssh nc2 "
  cd ~/docker/airflow 

  set -a && source ./config/.env && set +a

  # chmod -R o+r config

  docker compose --env-file ./config/.env down --volumes --remove-orphans
  docker compose --env-file ./config/.env up -d
"