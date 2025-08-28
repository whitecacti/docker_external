ssh nc2 "\
        mkdir -p ~/docker/coder; \
        mkdir -p ~/docker/coder/config; \
        mkdir -p ~/docker/coder/db_data; \
        mkdir -p ~/docker/coder/coder_data; \
        "

scp -r * nc2:~/docker/coder/

ssh nc2 "cd ~/docker/coder/; \
            docker compose --env-file ./config/.env down; \
            docker compose --env-file ./config/.env up -d"