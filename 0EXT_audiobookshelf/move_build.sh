# crate necessary folders & stop existing instance
ssh nc2 "
  mkdir -p ~/docker/audiobookshelf 
"

# copy over a couple files
rsync -avP * nc2:~/docker/audiobookshelf/ 

# restart instance
ssh nc2 "
  cd ~/docker/audiobookshelf
  docker compose --env-file ./config/.env down
  docker compose --env-file ./config/.env up -d
"