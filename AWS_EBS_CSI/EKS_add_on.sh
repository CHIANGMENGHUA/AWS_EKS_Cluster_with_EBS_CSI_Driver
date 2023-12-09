#!/bin/bash

# Load variables from .env file
source ../.env

eksctl create addon \
    --name aws-ebs-csi-driver \
    --cluster $my_cluster \
    --service-account-role-arn arn:aws:iam::$my_account_id:role/AmazonEKS_EBS_CSI_DriverRole --force
