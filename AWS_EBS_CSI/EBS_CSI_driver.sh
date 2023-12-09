#!/bin/bash

# Load variables from .env file
source ../.env

# Remove old IAM service account
eksctl delete iamserviceaccount \
      --name ebs-csi-controller-sa \
      --namespace kube-system \
      --cluster $my_cluster

# Create new IAM service account
eksctl create iamserviceaccount \
    --name ebs-csi-controller-sa \
    --namespace kube-system \
    --cluster "$my_cluster" \
    --role-name AmazonEKS_EBS_CSI_DriverRole \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
    --override-existing-serviceaccounts

# Function to check if IAM policy exists
iam_policy_exists() {
    local policy_arn="arn:aws:iam::$my_account_id:policy/$1"
    aws iam get-policy --policy-arn "$policy_arn" >/dev/null 2>&1
}

# Check and create KMS policy if needed
if iam_policy_exists "$KMS_Key_For_Encryption_On_EBS_Policy"; then
    echo "IAM policy '$KMS_Key_For_Encryption_On_EBS_Policy' already exists."

else
    echo "Creating IAM policy '$KMS_Key_For_Encryption_On_EBS_Policy'..."

    # Create KMS policy
    aws iam create-policy \
        --policy-name "$KMS_Key_For_Encryption_On_EBS_Policy" \
        --policy-document "file://kms_key_for_encryption_on_ebs.json"

    echo "IAM policy '$KMS_Key_For_Encryption_On_EBS_Policy' created successfully."
fi

# Attach KMS policy to IAM role
aws iam attach-role-policy \
    --policy-arn "arn:aws:iam::$my_account_id:policy/$KMS_Key_For_Encryption_On_EBS_Policy" \
    --role-name AmazonEKS_EBS_CSI_DriverRole
