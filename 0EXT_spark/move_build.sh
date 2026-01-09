# crate necessary folders & stop existing instance
ssh nc2 "
  rm -rf ~/docker/spark
  mkdir -p ~/docker/spark
  mkdir -p ~/docker/spark/config 
  mkdir -p ~/docker/spark/build 
"

# copy over a couple files
rsync -avP * nc2:~/docker/spark/ 

# restart instance
ssh nc2 "
  cd ~/docker/spark
  docker compose --env-file ./config/.env down -v
  docker compose --env-file ./config/.env up --force-recreate --remove-orphans -d
"