#!/bin/bash

source "${PWD}/config.ini"
source "color.sh"

delete_cluster() {
  echo "$(red_text "[-] Deleting cluster") $cluster_name ..."
  gcloud container clusters delete $cluster_name --quiet
  echo "$(red_text "[-] All the resources were deleted succesfully! 🍰 🍰 🍰")"
}

delete_cluster
