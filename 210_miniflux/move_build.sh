# pass the .env file for specified host
scp ../210_network/.* docker_host_210:~/envs/
scp ../210_network/* docker_host_210:~/envs/

ssh docker_host_210 "mkdir -p ~/docker/miniflux; \
                    mkdir -p ~/docker/miniflux/miniflux_db;"
scp docker-compose.yaml docker_host_210:~/docker/miniflux/docker-compose.yaml
ssh docker_host_210 "cd ~/docker/miniflux/; \
                    docker compose --env-file ~/envs/.env down; \
                    docker compose --env-file ~/envs/.env up -d"