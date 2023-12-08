#!/bin/bash

my_cluster=$(yq eval '.my_cluster' ".yaml")
my_eks_role_arn=$(yq eval '.my_eks_role_arn' ".yaml")
my_subnet_1_id=$(yq eval '.my_subnet_1_id' ".yaml")
my_subnet_2_id=$(yq eval '.my_subnet_2_id' ".yaml")
my_cluster_security_group_id=$(yq eval '.my_cluster_security_group_id' ".yaml")

aws eks create-cluster --name $my_cluster \
--role-arn $my_eks_role_arn \
--resources-vpc-config subnetIds=$my_subnet_1_id,$my_subnet_2_id,securityGroupIds=$my_cluster_security_group_id
