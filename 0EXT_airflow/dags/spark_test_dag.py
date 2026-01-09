from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

def _run_spark_job():
    import sys
    import socket
    from pyspark.sql import SparkSession

    # Fix for "Cannot call methods on a stopped SparkContext"
    # This ensures we start with a clean slate by stopping any lingering sessions.
    try:
        SparkSession.builder.getOrCreate().stop()
        print("Stopped existing SparkSession.")
    except Exception as e:
        print(f"No existing SparkSession to stop or error: {e}")
        pass

    # Initialize SparkSession
    # We set spark.driver.bindAddress to 0.0.0.0 to bind to all interfaces within the container.
    # We set spark.driver.host to the local IP so remote executors can reach the driver.
    # FOUR
    spark = SparkSession.builder \
        .appName("AirflowSparkTest") \
        .master("spark://spark-master:7077") \
        .config("spark.executor.memory", "2g") \
        .config("spark.driver.memory", "2g") \
        .config("spark.driver.host", "airflow-airflow-worker-1") \
        .config("spark.pyspark.python", "/home/airflow/.local/bin/python3.11") \
        .getOrCreate()

    print("SparkSession created successfully!")
    print(f"Spark Version: {spark.version}")

    # Example: Create a simple DataFrame
    data = [("Alice", 1), ("Bob", 2), ("Cathy", 3)]
    df = spark.createDataFrame(data, ["Name", "Age"])
    df.show()

    # Stop SparkSession when done
    spark.stop()
    print("SparkSession stopped.")

with DAG(
    dag_id='spark_test_dag',
    start_date=datetime(2023, 1, 1),
    schedule=None,
    catchup=False,
    tags=['spark', 'test'],
    default_args={
        'owner': 'airflow',
        'depends_on_past': False,
        'email_on_failure': False,
        'email_on_retry': False,
        'retries': 1,
        'retry_delay': timedelta(minutes=5),
    }
) as dag:
    run_spark_job_task = PythonOperator(
        task_id='run_spark_job',
        python_callable=_run_spark_job,
    )
