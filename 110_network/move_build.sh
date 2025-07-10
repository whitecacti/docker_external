scp .env docker_host_110:~/docker/network/.env 
scp docker-compose.yaml docker_host_110:~/docker/network/docker-compose.yaml
scp -rp ./config/caddy docker_host_110:~/docker/network/config/

echo ===== RESTART =====
ssh docker_host_110 'cd ~/docker/network/; \
                    docker compose --env-file .env down; \
                    docker compose --env-file .env up -d' 

echo ===== RESTARTING ALL SERVICES =====
ssh docker_host_110 'cd ~/docker/homepage/; \
                docker compose down; \
                docker compose up -d; \
            cd ~/docker/jupyterlab/; \
                docker compose down; \
                docker compose up -d; \
            cd ~/docker/syncthing/; \
                docker compose down; \
                docker compose up -d; \
             '