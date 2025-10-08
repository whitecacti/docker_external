from airflow import DAG
from airflow.providers.ssh.operators.ssh import SSHOperator
from datetime import datetime
from airflow.models import Variable
from airflow.operators.bash import BashOperator

user110 = Variable.get("110USER")

with DAG(
    dag_id='backup_docker_to_restic_dag',
    start_date=datetime(2023, 1, 1),
    schedule=None,
    catchup=False,
    tags=["whitecacti"],
) as dag:
    information = BashOperator(
        task_id='information',
        bash_command=f"printenv && echo '' && whoami && echo '' && id && ls -lah /opt/airflow",
    )

    rsync_to_staging_110 = SSHOperator(
        task_id='rsync_to_staging_110',
        ssh_conn_id='docker_host_110',
        command=f'rsync -avP * /home/{user110}/docker /tnas_vm_data/bu_staging/110 -v --stats --progress || true',
    )

    # echo "AcceptEnv RESTIC_PASSWORD" >> /etc/ssh/sshd_config
    # Do the above on host so the environment parameter in the SSHOperator works
    # Not the most secure thing, but better than logging the password to the Airflow logs
    # https://airflow.apache.org/docs/apache-airflow-providers-ssh/stable/_modules/airflow/providers/ssh/operators/ssh.html#:~:text=connection%20of%20%60ssh_conn_id%60.-,%3Aparam%20environment%3A,-a%20dict%20of
    staging_to_restic_110 = SSHOperator(
        task_id='staging_to_restic_110',
        ssh_conn_id='docker_host_110',
        environment={'RESTIC_PASSWORD': Variable.get("RESTIC_PASS_110_DOCKER")},
        command=f'restic -r /24bu_tnas/docker_bu/docker_host_110 backup /tnas_vm_data/bu_staging/110',
        
    )

    information >> rsync_to_staging_110 >> staging_to_restic_110