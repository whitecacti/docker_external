#!/bin/bash

# Default sync interval in seconds (1 hour)
INTERVAL=${SYNC_INTERVAL:-3600}

echo "Starting continuous sync: interval=${INTERVAL}s"

while true; do
  echo "$(date): Running sync..."
  /app/sync.sh
  echo "$(date): Sync complete. Sleeping for ${INTERVAL}s..."
  sleep "${INTERVAL}"
done
