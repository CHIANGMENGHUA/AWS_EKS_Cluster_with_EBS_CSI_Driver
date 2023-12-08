#!/bin/bash

# Specify the target directory
target_directory="AWS_EBS_CSI"

# Change to the target directory
cd "$target_directory" || exit 1

# Execute the .sh file
./IAM_OIDC_provider.sh
./EBS_CSI_driver.sh
./EKS_add_on.sh
