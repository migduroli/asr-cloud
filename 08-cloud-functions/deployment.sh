#!/usr/bin/env bash
gcloud functions deploy urandom-generator \
        --entry-point=get_urandom \
        --region europe-west1 \
        --runtime python38 \
        --trigger-http \
        --memory 128MB \
        --timeout 60s \
        --allow-unauthenticated