# crate necessary folders & stop existing instance
ssh nc2 "
  mkdir -p ~/docker/habits && \
  mkdir -p ~/docker/habits/beaver
"

# copy over a couple files
rsync -avP * nc2:~/docker/habits/ 

# restart instance
ssh nc2 "
  cd ~/docker/habits
  docker compose --env-file ./config/.env down
  docker compose --env-file ./config/.env up -d
"