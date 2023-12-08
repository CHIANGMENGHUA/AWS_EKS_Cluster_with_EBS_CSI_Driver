#!/bin/bash

my_cluster=$(yq eval '.my_cluster' "../.yaml")
my_account_id=$(yq eval '.my_account_id' "../.yaml")

eksctl create addon \
    --name aws-ebs-csi-driver \
    --cluster $my_cluster \
    --service-account-role-arn arn:aws:iam::$my_account_id:role/AmazonEKS_EBS_CSI_DriverRole --force
