ssh nc2 "mkdir -p ~/docker/api"

scp -r * nc2:~/docker/api/

ssh nc2 "cd ~/docker/api/; \
            docker compose --env-file ./config/.env down; \
            docker compose --env-file ./config/.env up -d"