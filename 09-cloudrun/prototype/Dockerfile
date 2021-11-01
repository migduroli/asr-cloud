FROM python:3.8

# STAGE TAG:
ARG STAGE
ENV DEPLOYMENT_TAG=$STAGE

# Create the root folder
RUN mkdir -p /app

# Copy all to /app
COPY . /app

WORKDIR /app
RUN pip install -r requirements.txt

CMD gunicorn \
    --bind :8080 \
    --workers 1 \
    --threads 2 \
    --timeout 60 \
    --worker-class uvicorn.workers.UvicornWorker \
    main:app