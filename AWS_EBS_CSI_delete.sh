#!/bin/bash

# Load variables from .env file
source .env

eksctl delete addon --cluster $my_cluster --name aws-ebs-csi-driver --preserve
