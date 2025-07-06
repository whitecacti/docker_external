#/bin/bash

# source ./load_env.sh
# in order to save the env variables, to your current terminal sessions

[ ! -f .env ] || while IFS='=' read -r key value; do
  if [[ $key == export* ]]; then
    key=${key#export }
  fi
  if [[ $key != \#* && -n $key ]]; then
    export "$key=$value"
  fi
done < .env