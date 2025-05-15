#/bin/bash

# source ./load_env.sh
# in order to save the env variables, to your current terminal sessions

[ ! -f .env ] || export $(grep -v '^#' .env | xargs)