# crate necessary folders & stop existing instance
ssh nc2 "
  mkdir -p ~/docker/kafka && \
  mkdir -p ~/docker/kafka/config/kafka
"

# copy over a couple files
rsync -avP * nc2:~/docker/kafka/ 

ssh nc2 "
  chmod +r ~/docker/kafka/config/kafka/*
  chmod +x ~/docker/kafka/config/kafka/topic-setup.sh
"

# restart instance
ssh nc2 "
  cd ~/docker/kafka
  PUBLIC_IP=$(curl -s -4 ifconfig.me) docker compose --env-file ./config/.env down --force-recreate
  PUBLIC_IP=$(curl -s -4 ifconfig.me) docker compose --env-file ./config/.env up --remove-orphans -d
"