from pyspark.sql import SparkSession

# Create or get a Spark session
spark = SparkSession.builder.appName("DropColumnsApp").getOrCreate()

# Create a simple DataFrame (In-memory data)
# We include "column1" and "column2" here to demonstrate dropping them later
data = [
    ("Alice", 34, "unwanted_data_A", "more_unwanted_A"),
    ("Bob", 45, "unwanted_data_B", "more_unwanted_B"),
    ("Cathy", 29, "unwanted_data_C", "more_unwanted_C")
]

columns = ["Name", "Age", "column1", "column2"]
df = spark.createDataFrame(data, columns)

print("--- Original DataFrame ---")
df.show()

# Drop the desired columns
columns_to_drop = ["column1", "column2"]
df_transformed = df.drop(*columns_to_drop)

print("--- Transformed DataFrame (Columns Dropped) ---")
df_transformed.show()

# Stop the Spark session
spark.stop()