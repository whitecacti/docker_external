# pass the .env file for specified host
scp ../210_network/.* docker_host_210:~/envs/
scp ../210_network/* docker_host_210:~/envs/

ssh docker_host_210 "mkdir -p ~/docker/homebox; 
            "
scp docker-compose.yaml docker_host_210:~/docker/homebox/docker-compose.yaml
ssh docker_host_210 "cd ~/docker/homebox/; \
            docker compose --env-file ~/envs/.env down; \
            docker compose --env-file ~/envs/.env up -d"