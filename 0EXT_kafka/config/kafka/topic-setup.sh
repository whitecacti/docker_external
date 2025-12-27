# Wait for the Kafka Broker to be ready before attempting to create topics
echo "Waiting for Kafka broker to be ready at broker:29092..."
cub kafka-ready -b broker:29092 1 60 -c /etc/kafka/jaas/client.properties

# https://docs.confluent.io/platform/current/installation/docker/development.html#confluent-platform-utility-belt-cub

echo "Kafka broker is ready. Initializing topics..."

# --- TOPICS AS CODE DEFINITIONS ---
# Define your topics here using kafka-topics.sh
# Syntax: --create --topic <TOPIC_NAME> --partitions <NUM_PARTITIONS> --replication-factor <NUM_REPLICAS>

# Things to remember 
# - Error while executing topic command : Unable to replicate the partition 2 time(s): The target replication factor of 2 cannot be reached because only 1 broker(s) are registered.

# https://stream.wikimedia.org/v2/stream/recentchange
# https://www.mediawiki.org/wiki/API:Recent_changes_stream
kafka-topics --bootstrap-server broker:29092 \
             --create \
             --topic wikipedia_all \
             --partitions 10 \
             --replication-factor 1 \
             --if-not-exists \
             --command-config /etc/kafka/jaas/client.properties \
             --config retention.ms=3600000 \
             --config cleanup.policy=delete

kafka-topics --bootstrap-server broker:29092 \
             --create \
             --topic cb_btc_usd \
             --partitions 10 \
             --replication-factor 1 \
             --if-not-exists \
             --command-config /etc/kafka/jaas/client.properties \
             --config retention.ms=3600000 \
             --config cleanup.policy=delete

kafka-topics --bootstrap-server broker:29092 \
             --create \
             --topic scapy_wardriving \
             --partitions 4 \
             --replication-factor 1 \
             --if-not-exists \
             --command-config /etc/kafka/jaas/client.properties \
             --config retention.ms=604800000 \
             --config cleanup.policy=compact

echo "Topic initialization complete!"