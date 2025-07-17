ssh docker_host_110 "\
                    mkdir -p ~/docker; \
                    mkdir -p ~/docker/jupyterlab; \
                    "

scp .env docker_host_110:~/docker/jupyterlab/.env
scp * docker_host_110:~/docker/jupyterlab/

ssh docker_host_110 "\
                    cd ~/docker/jupyterlab; \
                    docker compose build;
                    docker compose --env-file .env down; \
                    docker compose --env-file .env up -d; \
                    "