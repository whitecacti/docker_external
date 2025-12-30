FROM postgres:17-bookworm

# Install build dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    libssl-dev \
    pkg-config \
    clang \
    llvm-dev \
    libclang-dev \
    postgresql-server-dev-17 \
    postgresql-17-postgis-3 \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Environment variables
ENV CARGO_PGRX_VERSION=0.16.1
ENV PG_MAJOR=17

# Install cargo-pgrx
RUN cargo install --force --locked cargo-pgrx --version ${CARGO_PGRX_VERSION}

# Initialize pgrx using the system pg_config
RUN cargo pgrx init --pg${PG_MAJOR} $(which pg_config)

# Install pg_cron
WORKDIR /usr/src
RUN git clone https://github.com/citusdata/pg_cron.git
WORKDIR /usr/src/pg_cron
RUN make && make install

# Clone pg_parquet repo
WORKDIR /usr/src
RUN git clone https://github.com/CrunchyData/pg_parquet.git

# Build and install the extension
WORKDIR /usr/src/pg_parquet
# We use 'cargo pgrx install' which builds and copies artifacts to the postgres extension dir
RUN cargo pgrx install --release --features pg${PG_MAJOR}

# Install AWS CLI
RUN apt-get update && apt-get install -y awscli && rm -rf /var/lib/apt/lists/*

# Copy init script to create the extension automatically on startup
COPY sql/init.sql /docker-entrypoint-initdb.d/init.sql

# Cleanup to reduce image size (optional, but good practice, though Rust build artifacts are large)
# We keep the runtime requirements.
