ssh docker_host_110 "\
                    mkdir -p ~/docker; \
                    mkdir -p ~/docker/minio; \
                    mkdir -p ~/docker/minio/data; \
                    "

scp -r * docker_host_110:~/docker/minio/

ssh docker_host_110 "\
                    cd ~/docker/minio; \
                    docker compose --env-file ./config/.env down; \
                    docker compose --env-file ./config/.env up -d; \
                    "