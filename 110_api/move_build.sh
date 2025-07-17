ssh docker_host_110 "mkdir -p ~/docker/api"

scp * docker_host_110:~/docker/api/

ssh docker_host_110 'cd ~/docker/api/; \
                    docker compose build; \
                    docker compose --env-file .env down; \
                    docker compose --env-file .env up -d' 