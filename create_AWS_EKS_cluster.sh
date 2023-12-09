#!/bin/bash

# Load variables from .env file
source .env

aws eks create-cluster --name $my_cluster \
--role-arn $my_eks_role_arn \
--resources-vpc-config subnetIds=$my_subnet_1_id,$my_subnet_2_id,securityGroupIds=$my_cluster_security_group_id
