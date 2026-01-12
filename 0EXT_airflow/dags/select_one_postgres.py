from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.operators.bash import BashOperator
from datetime import datetime

with DAG(
    dag_id="postgres_operator_dag",
    start_date=datetime(2025, 4, 1),
    schedule=None,
    catchup=False,
) as dag:
    insert_task = SQLExecuteQueryOperator(
        task_id="insert_task",
        conn_id="postgres_de",
        sql="select 1;",
    )