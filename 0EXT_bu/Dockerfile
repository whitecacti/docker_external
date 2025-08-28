FROM amazonlinux:2

# Install AWS CLI
RUN yum update -y && \
    yum install -y aws-cli && \
    yum clean all

WORKDIR /app

# Copy scripts
COPY /scripts/sync.sh /scripts/run.sh /app/
RUN chmod +x /app/sync.sh /app/run.sh

# Default command: run continuous sync loop
CMD ["/app/run.sh"]
