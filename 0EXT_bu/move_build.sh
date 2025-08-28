ssh nc2 "mkdir -p ~/docker/nc2bu;"

scp -r * nc2:~/docker/nc2bu/

ssh nc2 "cd ~/docker/nc2bu/; \
            docker compose --env-file ./config/.env down; \
            docker compose --env-file ./config/.env up -d"