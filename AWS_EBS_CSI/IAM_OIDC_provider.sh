#!/bin/bash

# Load variables from YAML file
my_cluster=$(yq eval '.my_cluster' "../.yaml")

oidc_id=$(aws eks describe-cluster \
--name $my_cluster \
--query "cluster.identity.oidc.issuer" \
--output text | cut -d '/' -f 5)

echo $oidc_id
aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4
eksctl utils associate-iam-oidc-provider --cluster $my_cluster --approve
