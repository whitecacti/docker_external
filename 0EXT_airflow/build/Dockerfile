FROM apache/airflow:3.1.5

USER root
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
            wget curl llvm \
            tk-dev net-tools git unzip dnsutils \ 
            traceroute iputils-ping nmap hping3 \
            ncat vim postgresql-client \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
USER airflow

RUN pip install --no-cache-dir apache-airflow-providers-postgres lxml


# installing slim as per
    # https://airflow.apache.org/docs/docker-stack/index.html
# more customization