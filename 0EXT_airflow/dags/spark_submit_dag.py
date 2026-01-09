from airflow import DAG
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator
from datetime import datetime

with DAG('spark_submit_job',
         start_date=datetime(2022, 1, 1),
         schedule=None
        ) as dag:

    submit_job = SparkSubmitOperator(
        task_id='submit_job',
        application='/opt/airflow/sparkjobs/job.py', # Replace with the path to your PySpark script
        conn_id='spark_cluster_conn', # Connection ID for your Spark cluster
        conf={
            "spark.driver.bindAddress": "0.0.0.0",
            "spark.driver.host": "airflow-airflow-worker-1",
            "spark.pyspark.python": "/usr/local/bin/python3.11",
            "spark.pyspark.driver.python": "/home/airflow/.local/bin/python3.11"
        },
        # total_executor_cores='1',
        # executor_cores='1',
        executor_memory='2g',
        # num_executors='1',
        driver_memory='2g',
        verbose=False
    )