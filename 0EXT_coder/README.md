# To push the Dockerfile to dockerhub
cd docker_external/0EXT_coder/config
docker build -t XYZ/coder-XYZ:latest .
docker push XYZ/coder-XYZ:latest

# TODO
- modify terraform template to use the custom Dockerfile to simplify the install of a bunch of dev desktop utilities. 