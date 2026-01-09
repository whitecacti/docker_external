FROM apache/spark:3.5.0

USER root

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget build-essential libssl-dev zlib1g-dev \
    libncurses5-dev libncursesw5-dev libreadline-dev  \
    libsqlite3-dev libgdbm-dev libdb5.3-dev  \
    libbz2-dev libexpat1-dev liblzma-dev  \
    libffi-dev uuid-dev \
    && rm -rf /var/lib/apt/lists/*

# Download and compile Python 3.11
# Using 3.11.9 specifically
RUN wget https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tgz \
    && tar xzf Python-3.11.9.tgz \
    && cd Python-3.11.9 \
    && ./configure --enable-optimizations --with-ensurepip=install \
    && make -j$(nproc) \
    && make altinstall \
    && cd .. \
    && rm -rf Python-3.11.9 Python-3.11.9.tgz

# FORCE python3 to point to python3.11
# We backup the original python3 just in case, but overwrite the link
RUN mv /usr/bin/python3 /usr/bin/python3.8.original \
    && ln -s /usr/local/bin/python3.11 /usr/bin/python3 \
    && ln -s /usr/local/bin/python3.11 /usr/bin/python

# Point Spark env vars to the new binary explicitly as well
ENV PYSPARK_PYTHON=/usr/local/bin/python3.11
ENV PYSPARK_DRIVER_PYTHON=/usr/local/bin/python3.11

USER 185
