#!/bin/bash

gcloud compute addresses delete uk-vpn-ip --region europe-west2
gcloud compute instances delete vpn-instance --zone europe-west2-a
gcloud compute firewall-rules create london-vpn-udp