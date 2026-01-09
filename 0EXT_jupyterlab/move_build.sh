ssh nc2 "\
    mkdir -p ~/docker; \
    mkdir -p ~/docker/jupyterlab; \
    "

rsync -avP * nc2:~/docker/jupyterlab/

ssh nc2 "\
    cd ~/docker/jupyterlab; \
    docker compose build;
    docker compose --env-file .env down; \
    docker compose --env-file .env up -d; \
    "