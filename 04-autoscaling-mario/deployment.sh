#!/bin/bash

source "${PWD}/config.ini"
source "color.sh"

PROJECT=$(gcloud config get-value project)
APP_IMAGE_URI="gcr.io/$PROJECT/$app_img"
APP_IP=""

build_and_publish_image() {
  echo "$(green_text "[+] Building docker image:") $APP_IMAGE_URI"
  docker build --tag $APP_IMAGE_URI .

  echo "$(green_text "[+] Publishing docker image:") $APP_IMAGE_URI"
  docker push "$APP_IMAGE_URI"
}

create_instance_template() {
  echo "$(green_text "[+] Creating instance template:") $instance_template"
  gcloud beta compute instance-templates create-with-container $instance_template \
      --tags=http-server,https-server \
      --machine-type=e2-medium \
      --container-image=$APP_IMAGE_URI
  echo "$(green_text "[+] Creating instance template:") done!"
}

create_firewall_rule() {
    echo "$(green_text "[+] Creating firewall rules:") $app_port"
    gcloud compute firewall-rules create "default-allow-external-$app_port" \
      --direction=INGRESS \
      --priority=1000 \
      --network=default \
      --action=ALLOW \
      --rules=tcp:"$app_port" \
      --source-ranges=0.0.0.0/0
}

reserve_load_balancer_ip() {
  echo "$(green_text "[+] Reserving IP:") $app_ip for load balancer ..."
  gcloud compute addresses create $app_ip \
    --ip-version=IPV4 \
    --global \
    --quiet
  APP_IP=$(gcloud compute addresses list | awk '$1=="supermario-ip" {print $2}')
  echo "$(green_text "[+] Reserving IP:") ${redis_ip} done! [$(green_text "IP: $APP_IP")]"
}

create_instance_group() {
  echo "$(green_text "[+] Creating MIG:") $instance_group (template: $instance_template) ..."
  gcloud compute instance-groups managed create $instance_group \
    --base-instance-name=$instance_group \
    --template=$instance_template \
    --size=1 \
    --zones=us-central1-b,us-central1-c,us-central1-f \
    --instance-redistribution-type=PROACTIVE \
    --target-distribution-shape=EVEN

  echo "$(green_text "[+] Setting Autoscaling:") $instance_group (min: $min_num_replicas; max: $max_num_replicas; target-cpu: $target_cpu_utilization) ..."
  gcloud compute instance-groups managed set-autoscaling $instance_group \
    --region "us-central1" \
    --min-num-replicas "$min_num_replicas" \
    --max-num-replicas "$max_num_replicas" \
    --target-cpu-utilization "$target_cpu_utilization" \
    --cool-down-period "60" \
    --mode "on"

  echo "$(green_text "[+] Setting named ports:") $instance_group (http: 8080) ..."
  gcloud compute instance-groups managed set-named-ports $instance_group \
    --region=us-central1 \
    --named-ports=http:8080
}

create_health_check() {
  echo "$(green_text "[+] Creating health-check:") $app_img-healthcheck ..."
  gcloud compute health-checks create tcp "$app_img-healthcheck" \
      --port=8080
}

create_backend_service() {
  echo "$(green_text "[+] Creating backend service:") $app_img-backend ..."
  gcloud compute backend-services create "$app_img-backend" \
    --protocol=HTTP \
    --port-name=http \
    --health-checks="$app_img-healthcheck" \
    --global

  gcloud compute backend-services add-backend "$app_img-backend" \
    --instance-group=$instance_group \
    --instance-group-region=us-central1 \
    --balancing-mode=UTILIZATION \
    --max-utilization=0.8 \
    --global
}

create_http_frontend() {
  echo "$(green_text "[+] Creating frontend:") $app_img-frontend ..."
  gcloud compute url-maps create "$app_img-frontend" \
    --default-service "$app_img-backend"

  echo "$(green_text "[+] Setting forwarding rules:") ..."
  gcloud compute target-http-proxies create http-lb-proxy \
    --url-map="$app_img-frontend"

  gcloud compute forwarding-rules create http-content-rule \
      --address=$APP_IP \
      --global \
      --target-http-proxy=http-lb-proxy \
      --ports=8080

  echo "$(green_text "[+] Deployment finished succesfully! 🍄 🍄 🍄 ")"
}

build_and_publish_image
create_instance_template
create_firewall_rule
reserve_load_balancer_ip
create_instance_group
create_health_check
create_backend_service
create_http_frontend