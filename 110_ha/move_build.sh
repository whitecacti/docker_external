ssh docker_host_110 "\
        mkdir -p ~/docker; \
        mkdir -p ~/docker/ha; \
        mkdir -p ~/docker/ha/config; \
        mkdir -p ~/docker/ha/bu_config; \
        mkdir -p ~/docker/ha/bu; \
        "

scp -r * docker_host_110:~/docker/ha/

ssh docker_host_110 "\
    cd ~/docker/ha; \
    docker compose --env-file ./config/.env down; \
    docker compose --env-file ./config/.env up -d; \
    "