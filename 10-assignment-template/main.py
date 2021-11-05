import os

from google.cloud import storage
from google.cloud import bigquery

import pandas as pd


DATASET = "transactions"
TABLE = "records"
TABLE_ID = f"{DATASET}.{TABLE}"


def download_blob_as_dataframe(
        bucket_name,
        source_blob_name,
        destination_file_name="/tmp/transaction.csv"):
    """Downloads a blob from a bucket and returns it as a DataFrame"""

    storage_client = storage.Client()

    bucket = storage_client.bucket(bucket_name=bucket_name)

    blob = bucket.get_blob(source_blob_name)
    blob.download_to_filename(destination_file_name)

    print(
        f"Downloaded storage object {source_blob_name} "
        f"from bucket {bucket_name} to local file {destination_file_name}."
    )

    df = pd.read_csv(destination_file_name)

    os.remove(destination_file_name)
    return df


def upload_to_bigquery(dataframe, destination_table_id):
    """Uploads as dataframe into BigQuery"""

    bq = bigquery.Client()
    job_config = bigquery.LoadJobConfig(
        schema=[
            bigquery.SchemaField("ID", bigquery.enums.SqlTypeNames.STRING),
            bigquery.SchemaField("AMOUNT", bigquery.enums.SqlTypeNames.FLOAT)
        ],
        write_disposition="WRITE_APPEND"
    )

    print(f"Data to be ingested:\n{dataframe}")

    bq.load_table_from_dataframe(
        dataframe=dataframe,
        destination=destination_table_id,
        job_config=job_config
    )


def ingest_transaction(event, context):
    """The entrypoint of the Cloud Function"""
    bucket_name = event["bucket"]
    blob_name = event["name"]

    print(f"[i] Bucket name: {bucket_name}")
    print(f"[i] Filename storage path: {blob_name}")

    df = download_blob_as_dataframe(
        bucket_name=bucket_name,
        source_blob_name=blob_name,
    )

    upload_to_bigquery(
        dataframe=df,
        destination_table_id=TABLE_ID
    )


if __name__ == "__main__":
    # This is just for local testing purposes"

    event = {
        "bucket": "asr-cloud-test-01",
        "name": "transaction.csv"
    }

    ingest_transaction(event, None)
