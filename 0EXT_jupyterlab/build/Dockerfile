# For arm/m chip testing
FROM quay.io/jupyter/datascience-notebook:aarch64-python-3.11
    # Please remember to also switch the java version
# For linux host
# FROM quay.io/jupyter/datascience-notebook:aarch64-python-3.11

USER root
RUN apt-get update && \
      apt-get install -y --no-install-recommends \
            sudo \
            curl \
            vim \
            # iptools-ping \ 
            # netcat \
            unzip \
            rsync \
            build-essential \
            software-properties-common \
            ant \
            ssh \
            jq \
            libpq-dev \
            && apt-get clean \
            && rm -rf /var/lib/apt/lists/*

# Remember to remove unecessary packages to reduce build size
# --no-install-recommends # to only install what is necessary.

RUN pip install --no-cache-dir kafka-python polars pandas boto3 pyspark grpcio grpcio-tools grpcio-status confluent-kafka psycopg2 supabase 'faststream[kafka]'

# Install OpenJDK
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk --no-install-recommends && \
    apt-get install -y ant --no-install-recommends && \
    apt-get clean;

# Setup JAVA_HOME -- Necessary for CLI
ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk-arm64
RUN export JAVA_HOME

# Fix certificate issues
RUN apt-get install ca-certificates-java --no-install-recommends && \
    apt-get clean && \
    update-ca-certificates -f && \
    rm -rf /var/lib/apt/lists/* 

# This python package needs the JAVA_HOME env variable, otherwise the installation will fail
# https://stackoverflow.com/questions/78324619/problem-installing-apache-flink1-19-0-using-python-docker-3-9-3-12
# Upgrading pip wont hurt either...
RUN python -m ensurepip --upgrade
RUN python -m pip install --upgrade setuptools
# https://pypi.org/project/apache-flink/#history
# Only avaialble with python3.11, so make sure you are getting the right version in the FROM dockerfile tag
# RUN pip install apache-flink

# Switch to jovyan before installing Deno so it's owned by jovyan and not root
USER jovyan

# Tell the installer where to put Deno, and add it to PATH permanently
ENV DENO_INSTALL="/home/jovyan/.deno"
ENV PATH="${DENO_INSTALL}/bin:${PATH}"

# Install Deno, the Jupyter kernel, and Python libs in one RUN
# deno install options
# Options:
#  -y, --yes
#    Skip interactive prompts and accept defaults
# https://stackoverflow.com/questions/4642915/passing-parameters-to-bash-when-executing-a-script-fetched-by-curl
RUN curl -fsSL https://deno.land/install.sh | sh -s -- -y \
      && deno --version \
      && deno jupyter --install 

# Install scala kernel 
# https://almond.sh/docs/quick-start-install
RUN curl -Lo coursier https://git.io/coursier-cli \
      && chmod +x coursier \
      && ./coursier launch almond -- --install \
      && rm -f coursie

# Installing java kernel, might need to update versions time to time
# https://github.com/dflib/jjava
# https://dflib.org/jjava/docs/1.x/#_features
ENV JJAVA_JVM_OPTS=-Xmx8192m
RUN wget https://github.com/dflib/jjava/releases/download/1.0-a5/jjava-1.0-a5-kernelspec.zip \
      && mkdir workdir \
      && mv jjava-1.0-a5-kernelspec.zip workdir/ \
      && cd workdir \
      && unzip jjava-1.0-a5-kernelspec.zip \
      && cd .. \
      && jupyter kernelspec install workdir --user --name=java \
      && rm -rf workdir