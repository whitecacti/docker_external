from airflow import DAG
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from datetime import datetime
from airflow.models import Variable

with DAG('wardriving_etl_full_job',
         start_date=datetime(2023, 1, 1),
         schedule=None,
         catchup=False,
         tags=['spark', 'etl', 'wardriving']
        ) as dag:

    truncate_table = SQLExecuteQueryOperator(
        task_id="truncate_table",
        conn_id="postgres_de",
        sql="truncate descapy;",
    )

    etl_s3data = SparkSubmitOperator(
        task_id='etl_s3data',
        application='/opt/airflow/sparkjobs/wardriving_etl.py',
        conn_id='spark_cluster_conn',
        conf={
            "spark.driver.bindAddress": "0.0.0.0",
            "spark.driver.host": "airflow-airflow-worker-1",
            "spark.pyspark.python": "/usr/local/bin/python3.11",
            "spark.pyspark.driver.python": "/home/airflow/.local/bin/python3.11",
            "spark.jars.packages": "org.apache.hadoop:hadoop-aws:3.3.4",
            "spark.sql.parquet.enableVectorizedReader": "false"
        },
        executor_memory='2g',
        driver_memory='2g',
        verbose=False,
        env_vars={
            "S3_AWS_ACCESS_KEY_ID": Variable.get("S3_AWS_ACCESS_KEY_ID"),
            "S3_AWS_SECRET_ACCESS_KEY": Variable.get("S3_AWS_SECRET_ACCESS_KEY"),
            "S3_ENDPOINT_URL": Variable.get("S3_ENDPOINT_URL"),
            "BRONZE_LAYER_BUCKET": Variable.get("BRONZE_LAYER_BUCKET"),
            "SILVER_LAYER_BUCKET": Variable.get("SILVER_LAYER_BUCKET")
        }
    )

    load_table = SQLExecuteQueryOperator(
        task_id="load_table",
        conn_id="postgres_de",
        sql="COPY descapy FROM 's3://silver-layer/descapy/**/*.parquet' WITH (format 'parquet');",
    )

truncate_table >> etl_s3data >> load_table