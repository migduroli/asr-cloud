#!/bin/bash

source "${PWD}/config.ini"
source "color.sh"

set_compute_zone() {
  echo "$(green_text "[+] Setting the compute zone:") $zone ..."
  gcloud config set compute/zone $zone
}

create_cluster() {
  echo "$(green_text "[+] Creating GKE cluster:") $cluster_name ..."
  gcloud container clusters create "$cluster_name" \
    --num-nodes=3 \
    --enable-vertical-pod-autoscaling \
    --release-channel=rapid
}

apply_php_apache_manifest() {
  echo "$(green_text "[+] Applying $php_deployment manifest") ..."
  gcloud container clusters get-credentials $cluster_name

  kubectl apply -f "$php_manifest"
}

show_php_deployment() {
  echo "$(green_text "[+] Showing deployments") ..."
  gcloud container clusters get-credentials $cluster_name

  kubectl get deployment
}

hpa_autoscale_deployment() {
  echo "$(green_text "[+] Applying autoscale to $php_deployment") ..."
  gcloud container clusters get-credentials $cluster_name

  kubectl autoscale deployment php-apache \
      --cpu-percent="$cpu_threshold" \
      --min="$min_replicas" \
      --max="$max_replicas"
}

show_hpa_status() {
  # shellcheck disable=SC2005
  echo "$(green_text "[+] Getting HPA status:")"
  gcloud container clusters get-credentials $cluster_name

  kubectl get hpa
}

show_vpa_status() {
  echo "$(green_text "[+] Getting VPA status:")"
  gcloud container clusters describe $cluster_name | grep ^verticalPodAutoscaling -A 1
}

apply_hello_server_deployment() {
  echo "$(green_text "[+] Applying hello-server deployment") ..."
  gcloud container clusters get-credentials $cluster_name

  kubectl create deployment hello-server \
      --image=gcr.io/google-samples/hello-app:1.0
}

show_hello_deployment() {
  echo "$(green_text "[+] Showing deployments"): hello-server ..."
  gcloud container clusters get-credentials $cluster_name

  kubectl get deployment hello-server
}

set_resources_hello_server() {
  echo "$(green_text "[+] Setting resources requests CPU to hello-server") ..."
  gcloud container clusters get-credentials $cluster_name

  kubectl set resources deployment hello-server --requests=cpu=450m

  kubectl describe pod hello-server | sed -n "/Containers:$/,/Conditions:/p"
}


vpa_autoscale_off_deployment() {
  echo "$(green_text "[+] Applying VPA autoscale(off) to hello-server") ..."
  gcloud container clusters get-credentials $cluster_name

  kubectl apply -f hello-vpa.yaml

  kubectl describe vpa hello-server-vpa
}


vpa_autoscale_auto_deployment() {
  echo "$(green_text "[+] Applying VPA autoscale(on) to hello-server") ..."
  gcloud container clusters get-credentials $cluster_name

  kubectl apply -f hello-vpa-auto.yaml
}

manual_upscale_hello() {
  echo "$(green_text "[+] Manually scaling up to 2 replicas to observe VPA in action") ..."
  gcloud container clusters get-credentials $cluster_name

  kubectl scale deployment hello-server --replicas=2

  kubectl get pods -w
}

check_hpa_downsize_replicas() {
  gcloud container clusters get-credentials $cluster_name
  kubectl get hpa
}

check_vpa_downsize_cpu_requests() {
  gcloud container clusters get-credentials $cluster_name
  kubectl describe pod hello-server | sed -n "/Containers:$/,/Conditions:/p"

  ## If you still see a CPU request of 450m for either of the pods,
  ## manually set your CPU resource to the target with this command:

  #$> kubectl set resources deployment hello-server --requests=cpu=25m

  ## Sometimes VPA in auto mode may take a long time or set inaccurate upper
  ## or lower bound values without the time to collect accurate data.
  ## In order to not lose time in the lab, using the recommendation as
  ## if it were in "Off" mode is a simple solution.
}

enable_cluster_autoscaler() {
  echo "$(green_text "[+] Enabling cluster autoscaler:") $cluster_name ..."

  gcloud container clusters get-credentials $cluster_name
  gcloud beta container clusters update $cluster_name \
      --enable-autoscaling \
      --min-nodes $min_nodes \
      --max-nodes $max_nodes
}

show_cluster_nodes() {
  echo "$(green_text "[+] Show cluster nodes:") $cluster_name ..."
  gcloud container clusters get-credentials $cluster_name

  kubectl get nodes
}

enable_nap_autoscale() {
  echo "$(green_text "[+] Applying Node Auto Provisioning:") $cluster_name ..."

  # NAP can take a little bit of time and it's also highly likely it won't create
  # a new node pool for the scaling-demo cluster at its current state.

  gcloud container clusters update $cluster_name \
    --enable-autoprovisioning \
    --min-cpu 1 \
    --min-memory 2 \
    --max-cpu 45 \
    --max-memory 160
}

increase_demand() {
  gcloud container clusters get-credentials $cluster_name

  kubectl run -i --tty load-generator --rm \
    --image=busybox \
    --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
}

check_cluster_scaling() {
  gcloud container clusters get-credentials $cluster_name

  kubectl get deployment php-apache
}

# Provisioning environment:
#set_compute_zone
#create_cluster
#apply_php_apache_manifest

## Scale pods with HPA:
#show_php_deployment
#hpa_autoscale_deployment
#show_hpa_status

## Scale pods with VPA:
#show_vpa_status
#apply_hello_server_deployment
#show_hello_deployment
#set_resources_hello_server
#vpa_autoscale_off_deployment
#vpa_autoscale_auto_deployment
#manual_upscale_hello

## Check everything worked:
#check_hpa_downsize_replicas
#check_vpa_downsize_cpu_requests

## Cluster autoscaler:
#enable_cluster_autoscaler
#show_cluster_nodes

## Scale with NAP:
#enable_nap_autoscale

## Test with Larger Demand:
increase_demand