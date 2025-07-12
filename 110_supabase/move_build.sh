# crate necessary folders & stop existing instance
ssh docker_host_110 "
  mkdir -p ~/docker/supabase && \
  mkdir -p ~/docker/supabase/config
"

# copy over a couple files
scp ./config/.env docker_host_110:~/docker/supabase/.env
scp reset.sh docker-compose.yaml ./config/init.sql docker_host_110:~/docker/supabase/

# restart instance
ssh docker_host_110 "
  cd ~/docker/supabase && \
  docker compose --env-file .env down || true
  docker compose --env-file .env up -d
"