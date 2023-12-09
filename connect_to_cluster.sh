#!/bin/bash

# Load variables from .env file
source .env

vim /home/leon/.kube/config
aws eks --region $my_region update-kubeconfig --name $my_cluster
vim /home/leon/.kube/config
