# To push the Dockerfile to dockerhub
cd docker_external/0EXT_coder/config
docker build -t xyz/xyz:latest .
docker push xyz/xyz:latest

# TODO
- 

# Getting self hosted domains to work on the host
```bash
# adding the containter created by coder to the existing network
docker network connect ens_bridge coder-admin-xyz
# adding dns resolution to the container
# 172.21.0.2 is static IP defined in caddy docker compose file
sudo echo "172.21.0.2 xyz.xyz.com" >> /etc/hosts
```