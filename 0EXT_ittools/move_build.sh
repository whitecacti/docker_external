ssh nc2 "mkdir -p ~/docker/ittools;"

scp -r * nc2:~/docker/ittools/

ssh nc2 "cd ~/docker/ittools/; \
            docker compose --env-file ./config/.env down; \
            docker compose --env-file ./config/.env up -d"