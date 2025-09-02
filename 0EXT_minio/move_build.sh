ssh nc2 "\
        mkdir -p ~/docker; \
        mkdir -p ~/docker/minio; \
        mkdir -p ~/docker/minio/data; \
        "

scp -r * nc2:~/docker/minio/

ssh nc2 "\
    cd ~/docker/minio; \
    docker compose --env-file ./config/.env down; \
    docker compose --env-file ./config/.env up -d; \
    "