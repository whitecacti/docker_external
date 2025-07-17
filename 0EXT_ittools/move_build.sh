ssh netcup "mkdir -p ~/docker/ittools;"

scp .env netcup:~/docker/ittools/.env 
scp * netcup:~/docker/ittools/

ssh netcup "cd ~/docker/ittools/; \
            docker compose --env-file .env down; \
            docker compose --env-file .env up -d"