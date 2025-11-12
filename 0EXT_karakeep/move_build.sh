ssh nc2 "\
        mkdir -p ~/docker/karakeep; \
        mkdir -p ~/docker/searxng/config; \
        "

rsync -avP * nc2:~/docker/karakeep/

ssh nc2 "cd ~/docker/karakeep/; \
            docker compose --env-file ./config/.env down; \
            docker compose --env-file ./config/.env up -d"