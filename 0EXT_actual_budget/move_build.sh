# crate necessary folders & stop existing instance
ssh nc2 "
  mkdir -p ~/docker/actual_budget 
"

# copy over a couple files
rsync -avP * nc2:~/docker/actual_budget/ 

# restart instance
ssh nc2 "
  cd ~/docker/actual_budget
  docker compose --env-file ./config/.env down
  docker compose --env-file ./config/.env up -d
"