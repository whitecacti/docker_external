# this moves the configs and dags

rsync -avP * nc2:~/docker/airflow/

ssh nc2 "
  cd ~/docker/airflow 
  docker compose --env-file ./config/.env up airflow-init -d
"