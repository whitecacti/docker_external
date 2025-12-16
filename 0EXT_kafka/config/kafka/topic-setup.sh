# Wait for the Kafka Broker to be ready before attempting to create topics
echo "Waiting for Kafka broker to be ready at broker:29092..."
cub kafka-ready -b broker:29092 1 60 -c /etc/kafka/jaas/client.properties

# https://docs.confluent.io/platform/current/installation/docker/development.html#confluent-platform-utility-belt-cub

echo "Kafka broker is ready. Initializing topics..."

# --- TOPICS AS CODE DEFINITIONS ---
# Define your topics here using kafka-topics.sh
# Syntax: --create --topic <TOPIC_NAME> --partitions <NUM_PARTITIONS> --replication-factor <NUM_REPLICAS>

kafka-topics --bootstrap-server broker:29092 \
             --create \
             --topic new_data_topic \
             --partitions 1 \
             --replication-factor 1 \
             --if-not-exists \
             --command-config /etc/kafka/jaas/client.properties

# Topic 3: Example of a third topic
kafka-topics --bootstrap-server broker:29092 \
             --create \
             --topic sensor_readings_raw \
             --partitions 5 \
             --replication-factor 1 \
             --if-not-exists \
             --command-config /etc/kafka/jaas/client.properties

echo "Topic initialization complete!"