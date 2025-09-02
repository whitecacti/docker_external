ssh nc2 "\
        mkdir -p ~/docker/searxng; \
        mkdir -p ~/docker/searxng/config; \
        "

scp -r * nc2:~/docker/searxng/

ssh nc2 "cd ~/docker/searxng/; \
            docker compose --env-file ./config/.env down; \
            docker compose --env-file ./config/.env up -d"