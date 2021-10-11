#!/bin/bash

source "${PWD}/config.ini"
source "color.sh"

PROJECT=$(gcloud config get-value project)
REDIS_VM_IP=""

create_redis_ip() {
  echo "$(green_text "[+] Reserving IP:") $redis_ip for redis server ..."
  gcloud compute addresses create ${redis_ip} --quiet
  REDIS_VM_IP=$(gcloud compute addresses list | awk '$1=="redis-ip" {print $2}')
  echo "$(green_text "[+] Deploying:") ${redis_ip} done! [$(green_text "IP: $REDIS_VM_IP")]"
}

create_firewall_rules() {
  echo "$(green_text "[+] Opening ports: $redis_port, $app_port") ..."

  gcloud compute firewall-rules create "default-allow-external-$redis_port" \
      --direction=INGRESS \
      --priority=1000 \
      --network=default \
      --action=ALLOW \
      --rules=tcp:"$redis_port" \
      --source-ranges=0.0.0.0/0

  gcloud compute firewall-rules create "default-allow-external-$app_port" \
      --direction=INGRESS \
      --priority=1000 \
      --network=default \
      --action=ALLOW \
      --rules=tcp:"$app_port" \
      --source-ranges=0.0.0.0/0

    echo "$(green_text "[+] Opening ports:") done!"
}

deploy_redis_server() {
  echo "$(green_text "[+] Creating VM:") $redis_server (img: ${redis_image}) ..."
  gcloud compute instances create-with-container $redis_server \
      --machine-type="$machine_type" \
      --container-image="$redis_image" \
      --address="$REDIS_VM_IP" \
      --tags=http-server,https-server \
      --quiet
  echo "$(green_text "[+] Deploying:") $redis_server done!"
}

build_and_deploy_app() {
  app_image_uri="gcr.io/$PROJECT/$app_img"

  echo "$(green_text "[+] Building docker image:") $app_image_uri"
  docker build --tag $app_image_uri \
      --build-arg REDIS_IP=$REDIS_VM_IP \
      .

  echo "$(green_text "[+] Publishing docker image:") $app_image_uri"
  docker push "$app_image_uri"

  echo "$(green_text "[+] Deploying App:") $app_name [connected to redis IP: $REDIS_VM_IP]"
  gcloud compute instances create-with-container $app_name \
      --machine-type=$machine_type \
      --container-image=$app_image_uri \
      --tags=http-server,https-server \
      --container-env=REDIS_IP_GCP=$REDIS_VM_IP \
      --quiet

  echo "$(green_text "[+] Deployment finished succesfully! 🥳 🥳 🥳")"
}

create_redis_ip
create_firewall_rules
deploy_redis_server
build_and_deploy_app