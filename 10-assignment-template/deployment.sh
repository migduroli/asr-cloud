#!/usr/bin/env bash

## !!! IMPORTANT:
## Uncomment the following line for the first running. After you've authenticated
## once, you won't need to run this line anymore:
# gcloud auth application-default login

# Check if blob name exists, else it's created
gsutil ls -b gs://asr-cloud-test-01 || gsutil mb -l ASIA gs://asr-cloud-test-01

# Copy the example transaction in the desired bucket:
gsutil cp transaction.csv gs://asr-cloud-test-01

# Check if dataset transactions exists, else it's created
bq ls transactions || bq mk -d transactions

# Check if table records exists, else it's created
bq ls transactions | grep records || bq mk --table transactions.records ID:STRING,AMOUNT:FLOAT

# Deployment:
gcloud functions deploy ingester-transactions \
        --entry-point=ingest_transaction \
        --runtime python38 \
        --trigger-resource asr-cloud-test-01 \
        --trigger-event google.storage.object.finalize \
        --memory 512MB \
        --timeout 60s