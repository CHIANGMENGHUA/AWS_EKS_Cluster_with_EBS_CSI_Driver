#!/bin/bash

# Load variables from .env file
source ../.env

oidc_id=$(aws eks describe-cluster \
--name $my_cluster \
--query "cluster.identity.oidc.issuer" \
--output text | cut -d '/' -f 5)

echo $oidc_id
aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4
eksctl utils associate-iam-oidc-provider --cluster $my_cluster --approve
