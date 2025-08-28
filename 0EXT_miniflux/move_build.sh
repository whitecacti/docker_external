ssh nc2 "mkdir -p ~/docker/miniflux; \
        mkdir -p ~/docker/miniflux/data;"

scp -r * nc2:~/docker/miniflux/

ssh nc2 "cd ~/docker/miniflux/; \
            docker compose --env-file ./config/.env down; \
            docker compose --env-file ./config/.env up -d"
