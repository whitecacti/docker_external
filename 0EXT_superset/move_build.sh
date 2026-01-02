# Backup, if necessary
# rsync -Prltvc --exclude 'node_modules' nc2:/home/XYZ/XYZ/superset/ /Users/XYZ/XYZ/XYZ/bu/0EXT_superset

# crate necessary folders & stop existing instance
ssh nc2 "
  mkdir -p ~/docker
  cd ~/docker
  # git clone creates the dir if/when necessary
  git clone https://github.com/apache/superset.git
  mkdir -p ~/docker/superset/bu
  mkdir -p ~/docker/superset/config
"

# a
# v
# P
# I - ignore-times, ie overwrite
rsync -avPI * nc2:~/docker/superset/ 

# restart instance
ssh nc2 "
  cd ~/docker/superset

  if [ -f ./config/.env.s3 ]; then
    set -a
    source ./config/.env.s3
    set +a

    docker exec -e PGPASSWORD=\"\$PGPASSWORD\" -t superset-db_superset-1 pg_dump -U \"\$PGUSER\" \"\$PGDB\" > ./bu/db_superset_pgdump_\$(date +%Y%m%d_%H%M%S)
    aws s3 sync ./bu/ \"\$S3_BUCKET_KEY\" --endpoint-url \"\$S3_ENDPOINT_URL\"
  else
    echo 'Error: .env.s3 file not found. Skipping S3 upload.'
  fi

  docker compose --env-file ./config/.env --env-file ./docker/.env down
  docker compose --env-file ./config/.env --env-file ./docker/.env up -d --remove-orphans
"