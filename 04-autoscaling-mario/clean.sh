#!/bin/bash

source "${PWD}/config.ini"
source "color.sh"

delete_frontend() {
  echo "$(red_text "[-] Deleting frontend services") ..."
  gcloud compute forwarding-rules delete http-content-rule --global --quiet
  gcloud compute target-http-proxies delete http-lb-proxy --quiet
  gcloud compute url-maps delete "$app_img-frontend" --quiet
}

delete_backend() {
  echo "$(red_text "[-] Deleting backend services") ..."
  gcloud compute backend-services delete "$app_img-backend" --global --quiet
}

delete_healthchek() {
  echo "$(red_text "[-] Deleting health checks") ..."
  gcloud compute health-checks delete "$app_img-healthcheck" --global --quiet
}

delete_instance_group() {
  echo "$(red_text "[-] Deleting MIG") ..."
  gcloud compute instance-groups managed delete $instance_group --region=us-central1 --quiet
}

delete_firewall_rule() {
  echo "$(red_text "[-] Deleting firewall rules") ..."
  gcloud compute firewall-rules delete "default-allow-external-$app_port" --quiet
}

delete_load_balancer_ip() {
  echo "$(red_text "[-] Deleting IP:") $app_ip ..."
  gcloud compute addresses delete $app_ip --global --quiet
}

delete_instance_template() {
  echo "$(red_text "[-] Deleting instance templates") ..."
  gcloud beta compute instance-templates delete $instance_template --quiet
  echo "$(red_text "[-] All the resources were deleted succesfully! 🍰 🍰 🍰")"
}


delete_frontend
delete_backend
delete_healthchek
delete_instance_group
delete_load_balancer_ip
delete_firewall_rule
delete_instance_template
