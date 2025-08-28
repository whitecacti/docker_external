ssh nc2 'mkdir -p ~/docker/homebox;'
ssh nc2 'mkdir -p ~/docker/homebox/data;'

scp -r * nc2:~/docker/homebox/
ssh -t nc2 "sudo chown -R 65532:65532 ~/docker/homebox/data/"

ssh nc2 "cd ~/docker/homebox/; \
            docker compose --env-file ./config/.env down; \
            docker compose --env-file ./config/.env up -d"