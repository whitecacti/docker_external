ssh docker_host_110 "mkdir -p ~/docker; \
                    mkdir -p ~/docker/syncthing; \
                    mkdir -p ~/docker/syncthing/config; \
                    "
scp docker-compose.yaml docker_host_110:~/docker/syncthing/docker-compose.yaml
scp ./config/.env docker_host_110:~/docker/syncthing/config/.env
ssh docker_host_110 "cd ~/docker/syncthing; \
                    docker compose --env-file ./config/.env down; \
                    docker compose --env-file ./config/.env up -d"