# using python 3.11 to match with jupyter and spark
FROM apache/airflow:3.1.5-python3.11

USER root
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
            wget curl llvm \
            tk-dev net-tools git unzip dnsutils \ 
            traceroute iputils-ping nmap hping3 \
            ncat vim postgresql-client \
            openjdk-17-jre-headless \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && ln -s /usr/lib/jvm/java-17-openjdk-$(dpkg --print-architecture) /usr/lib/jvm/java-17-openjdk

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk

USER airflow

RUN pip install --no-cache-dir \
    apache-airflow-providers-postgres \
    apache-airflow-providers-apache-spark \
    apache-airflow-providers-apache-kafka \
    apache-airflow-providers-discord \
    apache-airflow-providers-docker \
    apache-airflow-providers-smtp \
    apache-airflow-providers-amazon \
    apache-airflow-providers-apache-iceberg \
    pyspark==3.5.0 \
    lxml


# installing slim as per
    # https://airflow.apache.org/docs/docker-stack/index.html