#!/bin/bash

# Load variables from YAML file
my_cluster=$(yq eval '.my_cluster' ".yaml")

eksctl delete addon --cluster $my_cluster --name aws-ebs-csi-driver --preserve
