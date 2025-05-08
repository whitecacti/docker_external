#/bin/bash
sudo [ ! -f .env ] || export $(grep -v '^#' .env | xargs)