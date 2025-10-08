# restart instance
ssh docker_host_110 "
  cd ~/docker/airflow && \
  docker compose --env-file ./config/.env down --volumes --remove-orphans \
    || docker compose down --volumes --remove-orphans \
    || true
  docker compose --env-file ./config/.env build
"

# crate necessary folders & stop existing instance
ssh docker_host_110 "\
  mkdir -p ~/docker/airflow && \
  rm -rf ~/docker/airflow/dags 2>/dev/null || true && \
  rm -rf ~/docker/airflow/plugins 2>/dev/null || true && \
  mkdir -p ~/docker/airflow/config && \
  mkdir -p ~/docker/airflow/dags && \
  mkdir -p ~/docker/airflow/plugins \
  mkdir -p ~/docker/airflow/logs && \
  # it is fine for the logs to fail chaning perms, 
  # this only really matters on init
  chmod -R 777 ~/docker/airflow/logs 2>/dev/null || true
"

# copy over a couple files
rsync -avP * docker_host_110:~/docker/airflow/

# restart instance
ssh docker_host_110 "
  cd ~/docker/airflow 
  docker compose --env-file ./config/.env down --volumes --remove-orphans || true
  # sudo chown ${AIRFLOW_UID}:${AIRFLOW_GID} ./config/airflow_key_secret ./config/airflow_key_secret.pub
  # sudo chmod 600 ./config/airflow_key_secret ./config/airflow_key_secret.pub
  # a key can only be r/w by owner, no group perms!
  docker compose --env-file ./config/.env up -d
"