# crate necessary folders & stop existing instance
ssh nc2 "
  mkdir -p ~/docker/postgres 
"

# copy over a couple files
rsync -avP * nc2:~/docker/postgres/ 

# restart instance
ssh nc2 "
  cd ~/docker/postgres
  docker compose --env-file ./config/.env down
  # docker compose --env-file ./config/.env up -d --build
  docker compose --env-file ./config/.env up -d
"