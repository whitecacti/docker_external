ssh netcup "\
        mkdir -p ~/docker/searxng; \
        mkdir -p ~/docker/searxng/config; \
        "

scp -r * netcup:~/docker/searxng/

ssh netcup "cd ~/docker/searxng/; \
            docker compose --env-file ./config/.env down; \
            docker compose --env-file ./config/.env up -d"