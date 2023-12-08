#!/bin/bash

my_cluster=$(yq eval '.my_cluster' ".yaml")
my_region=$(yq eval '.my_region' ".yaml")

vim /home/leon/.kube/config
aws eks --region $my_region update-kubeconfig --name $my_cluster
vim /home/leon/.kube/config
