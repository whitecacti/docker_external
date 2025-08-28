#!/bin/bash

echo "$(date): Starting sync..."

# Build AWS sync command
CMD_ARGS="aws s3 sync /data s3://nc2bu"
if [ -n "$AWS_ENDPOINT_URL" ]; then
  CMD_ARGS+=" --endpoint-url $AWS_ENDPOINT_URL"
fi

# Execute sync
eval "$CMD_ARGS"

echo "$(date): Sync completed"
