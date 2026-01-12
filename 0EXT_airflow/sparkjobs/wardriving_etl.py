import os
import boto3
from botocore.exceptions import ClientError
from pyspark.sql import SparkSession
from pyspark.sql.functions import input_file_name, col

# --- Configuration ---
ACCESS_KEY_ID = os.getenv('S3_AWS_ACCESS_KEY_ID')
SECRET_ACCESS_KEY = os.getenv('S3_AWS_SECRET_ACCESS_KEY')
LOCAL_S3_PROXY_SERVICE_URL = os.getenv('S3_ENDPOINT_URL')
SOURCE_BUCKET = os.getenv('BRONZE_LAYER_BUCKET')
SOURCE_PATH = "topics/scapy_wardriving/"
DEST_BUCKET = os.getenv('SILVER_LAYER_BUCKET')
DEST_PATH = "descapy/"

def get_s3_client():
    return boto3.client('s3',
        aws_access_key_id=ACCESS_KEY_ID,
        aws_secret_access_key=SECRET_ACCESS_KEY,
        endpoint_url=LOCAL_S3_PROXY_SERVICE_URL
    )

def delete_bucket_contents(bucket_name):
    """
    Empty the S3 bucket using boto3 before processing.
    """
    s3_client = get_s3_client()
    try:
        print(f"Starting cleanup for bucket: {bucket_name}")
        paginator = s3_client.get_paginator('list_object_versions')
        page_iterator = paginator.paginate(Bucket=bucket_name)

        for page in page_iterator:
            objects_to_delete = []
            if 'Versions' in page:
                objects_to_delete.extend({'Key': obj['Key'], 'VersionId': obj['VersionId']} for obj in page['Versions'])
            if 'DeleteMarkers' in page:
                objects_to_delete.extend({'Key': obj['Key'], 'VersionId': obj['VersionId']} for obj in page['DeleteMarkers'])

            if objects_to_delete:
                print(f"Deleting batch of {len(objects_to_delete)} objects...")
                s3_client.delete_objects(Bucket=bucket_name, Delete={'Objects': objects_to_delete, 'Quiet': True})
        
        print("Bucket cleanup successful.")
    except ClientError as e:
        # If bucket doesn't exist, that's fine, Spark will create it (or we might need to create it)
        if e.response['Error']['Code'] == 'NoSuchBucket':
            print(f"Bucket {bucket_name} does not exist. It will be created during write.")
        else:
            print(f"AWS Error: {e}")
    except Exception as e:
        print(f"Unexpected Error during cleanup: {e}")

def run_spark_job():
    # Initialize Spark Session with Hadoop-AWS
    spark = SparkSession.builder \
        .appName("WardrivingETL") \
        .getOrCreate()

    # Configure S3A
    hadoop_conf = spark.sparkContext._jsc.hadoopConfiguration()
    hadoop_conf.set("fs.s3a.access.key", ACCESS_KEY_ID)
    hadoop_conf.set("fs.s3a.secret.key", SECRET_ACCESS_KEY)
    hadoop_conf.set("fs.s3a.endpoint", LOCAL_S3_PROXY_SERVICE_URL)
    hadoop_conf.set("fs.s3a.path.style.access", "true")
    
    # 1. Read Data
    full_source_path = f"s3a://{SOURCE_BUCKET}/{SOURCE_PATH}"
    print(f"Reading from: {full_source_path}")
    
    try:
        df = spark.read.json(full_source_path) \
            .withColumn("source_file", input_file_name())
        
        # 2. Transform Data
        # Select specific columns and handle deduplication
        silverdf = df.select(
            "ssid", "bssid", "channel",
            "latitude", "longitude", "signal_strength",
            "time", "source_file", "year", "month", "day", "hour"
        ).distinct()

        # Create partition columns
        silverdf_with_partitions = silverdf \
            .withColumn("part_year", col("year")) \
            .withColumn("part_month", col("month")) \
            .withColumn("part_day", col("day")) \
            .withColumn("part_hour", col("hour"))

        # 3. Write Data
        full_dest_path = f"s3a://{DEST_BUCKET}/{DEST_PATH}"
        print(f"Writing to: {full_dest_path}")
        
        silverdf_with_partitions.write \
            .mode("overwrite") \
            .partitionBy("part_year", "part_month", "part_day", "part_hour") \
            .parquet(full_dest_path)
            
        print("Write completed successfully.")
        
    except Exception as e:
        print(f"Error during Spark processing: {e}")
    finally:
        spark.stop()

if __name__ == "__main__":
    # Optional: Clean the bucket first as per your snippet
    delete_bucket_contents(DEST_BUCKET)
    
    # Run the processing job
    run_spark_job()