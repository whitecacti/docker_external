ssh docker_host_110 "\
        mkdir -p ~/docker; \
        mkdir -p ~/docker/network/; \
        mkdir -p ~/docker/network/volumes/; \
        mkdir -p ~/docker/network/volumes/adguard_config; \
        mkdir -p ~/docker/network/volumes/adguard_work; \
        mkdir -p ~/docker/network/volumes/caddy_data; \
        mkdir -p ~/docker/network/volumes/caddy_config; \
        mkdir -p ~/docker/network/volumes/caddy_letsencrypt; \
        mkdir -p ~/docker/network/volumes/caddy_lib_letsencrypt; \
        "

rsync -avP * docker_host_110:~/docker/network/

echo ===== RESTART =====
ssh docker_host_110 'cd ~/docker/network/; \
                    docker compose --env-file .env down; \
                    docker compose --env-file .env up -d' 