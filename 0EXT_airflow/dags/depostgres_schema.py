from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from datetime import datetime

def list_schemas():
    """
    Connects to the postgres_de connection and prints all available schemas.

    TESTING2
    """
    hook = PostgresHook(postgres_conn_id="postgres_de")
    
    print("Connecting to postgres_de to fetch schemas...")
    # Query information_schema to get a list of all schemas
    schemas = hook.get_records("SELECT schema_name FROM information_schema.schemata;")
    
    print(f"Successfully retrieved {len(schemas)} schemas:")
    for schema in schemas:
        # get_records returns a list of tuples
        print(f" - {schema[0]}")

with DAG(
    dag_id="print_postgres_schemas",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    doc_md=__doc__,
    tags=["example", "postgres_de"],
) as dag:

    print_schemas_task = PythonOperator(
        task_id="print_schemas",
        python_callable=list_schemas,
    )