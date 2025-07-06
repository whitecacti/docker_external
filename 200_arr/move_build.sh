# pass the .env file for specified host
scp ../200_network/.* docker_host_200:~/envs/
scp ../200_network/* docker_host_200:~/envs/

ssh docker_host_200 "mkdir -p ~/docker/arr; \
                    "
scp docker-compose.yaml docker_host_200:~/docker/arr/docker-compose.yaml
ssh docker_host_200 "cd ~/docker/arr; \
                    docker compose --env-file ~/envs/.env down; \
                    docker compose --env-file ~/envs/.env up -d"