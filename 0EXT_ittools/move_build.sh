ssh netcup "mkdir -p ~/docker/ittools;"

scp .env netcup:~/docker/ittools/.env 
scp * netcup:~/docker/ittools/

ssh netcup "cd ~/docker/ittools/; \
            docker compose down; \
            docker compose up -d"