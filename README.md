# `Create AWS EKS Cluster and Setup EBS CSI Driver`

## Prerequisite:

### Create IAM Role with AWS account (replace <...> with your configurations) using AWS console:

#### Your AWS EKS Role:

1. Use AWS console to get into
   > IAM / Roles > `Create role`
2. Add permissions:
   - `AmazonEKSServicePolicy`
3. Role name: `<Your-AWS-EKS-Role-Name>`
4. Create role

> Create

#### Your AWS EKS Node Group Role:

1. Use AWS console to get into
   > IAM / Roles > `Create role`
2. Add permissions:
   - `AmazonEC2ContainerRegistryReadOnly`
   - `AmazonEKS_CNI_Policy`
   - `AmazonEKSWorkerNodePolicy`
3. Role name: `<Your-AWS-EKS-Node-Group-Role-Name>`
4. Create role

> Create

---

### Create Security Group in AWS EC2 Service (replace <...> with your configurations) using AWS console:

#### Your AWS Cluster Security Group:

1. Use AWS console to get into
   > EC2 / Security Groups > `Create security group`
2. Security group name: `<Your-Cluster-Security-Group-Name>`
3. Description: `<Your-Cluster-Security-Group-Description>`
4. Set your desired Inbound rules & Outbound rules
5. Create security group

> Create

---

### Create your Cluster VPC & Subnet:

- Simple: [https://www.youtube.com/watch?v=ApGz8tpNLgo](https://www.youtube.com/watch?v=ApGz8tpNLgo)
- Enhanced: [https://www.youtube.com/watch?v=g2JOHLHh4rI](https://www.youtube.com/watch?v=g2JOHLHh4rI)

---

### Tools:

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [eksctl](https://eksctl.io/installation/)
- [yq](https://github.com/mikefarah/yq)

---

### Access key:

1. Use AWS console to get into

   > IAM / Users / `<Your-Account>` / Security credentials / Access keys > `Create access key`

   - Command Line Interface (CLI)

     > Next

   - Create access key

   > Create

   - Save Access keys as a .CSV file

2. Use terminal to login AWS CLI using Access key by following commands:

   ```bash
   aws configure
   # AWS Access Key ID [...]: <Your-Access-key-ID>
   # AWS Secret Access Key [...]: <Your-Secret-access-key>
   # Default region name [...]: <Your-Cluster-Region>
   # Default output format [...]: <json/yaml/...>

   aws sts get-caller-identity
   # Verify your AWS CLI account
   ```

> Done

---

### Create KMS key:

#### Example:

1. Use AWS console to get into

   > KMS / Customer managed keys > `Create key`

2. Configure key:

   - Key type: `Symmetric`
   - Key usage: `Encrypt and decrypt`
   - Advanced options:
     - Key material origin: `KMS - recommended`
     - Regionality: `Single-Region key`

   > next

3. Add labels:

   - Alias: `<Your-KMS-key-Name>`

   > next

4. Define key administrative permissions:

   - Key administrators: `<Select-Your-IAM-users>`
   - Key deletion: `<on> / Allow key administrators to delete this key.`

   > next

5. Define key usage permissions:

   - Key users: `<Select-Your-IAM-users>`
   - Other AWS accounts: `no`

   > next

6. Review

   > Finish

---

## Start create cluster and setup EBS CSI Driver:

### 1. Create .yaml file and .json file

- Create a `.yaml` file in `"AWS_EKS/"` directory with the following contents, replacing `<...>` with your configurations:

```yaml
my_cluster: <Your-Cluster-Name>
my_eks_role_arn: <Your-AWS-EKS-Role-Arn>
my_subnet_1_id: <Your-Vpc-Subnet-1>
my_subnet_2_id: <Your-Vpc-Subnet-2>
my_subnet_3_id: <Your-Vpc-Subnet-3>
my_cluster_security_group_id: <Your-Cluster-Security-Group>
my_account_id: <Your-AWS-Account-ID>
my_region: <Your-Cluster-Region>
AmazonEKS_EBS_CSI_DriverRole: <Your-AmazonEKS-EBS-CSI-DriverRole-Name>
KMS_Key_For_Encryption_On_EBS_Policy: <Your-KMS-Key-For-Encryption-On-EBS-Policy-Name>
```

- Create a file `kms_key_for_encryption_on_ebs.json` in `"AWS_EKS/AWS_EBS_CSI/"` directory with the following contents, replacing `<Your-AWS-KMS-Key-ARN>` with your KMS key ARN that key created in previous:
  - Get into AWS console:
    > KMS / Customer managed keys / `<Your-KMS-key>` / ARN: `<Your-AWS-KMS-Key-ARN>`

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant"],
      "Resource": ["<Your-AWS-KMS-Key-ARN>"],
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": ["<Your-AWS-KMS-Key-ARN>"]
    }
  ]
}
```

---

### 2. Use terminal (in the `"AWS_EKS"` directory) to create a new cluster by running the following commands:

```bash
./create_AWS_EKS_cluster.sh
```

### `Or` use AWS console to create a new cluster:

### Example:

(1) Navigate to EKS Console:

> EKS / Clusters > `Create cluster`

(2) Fill in the details:

- **Name:** `<Your-AWS-EKS-Cluster-Name>`
- **Kubernetes version:** `<Your-Desired-Kubernetes-version>`
- **Cluster service role:** `<Your-AWS-EKS-Role-Name>`

> next

(3) Specify networking:

- **Networking:**

  - VPC: `<Your Cluster VPC>`
  - Subnets:
    - `<Your-Vpc-Subnet-1>`
    - `<Your-Vpc-Subnet-2>`
  - Security groups:`<Your-Cluster-Security-Group-Name>`
  - Choose cluster IP address family: `IPv4`

- **Cluster endpoint access:**

  - `Public`

> next

(4) Configure observability:

- **Metrics:**

  - Prometheus: `on`

- **Control plane logging:**

  - API server: `off`
  - Audit: `off`
  - Authenticator: `off`
  - Controller manager: `off`
  - Scheduler: `off`

> Next

(5) Select add-ons:

- `Keep Default`

> Next

(6) Configure selected add-ons settings:

- `Keep Default`

> Next

(7) Review and create:

> Create

(8) Wait for EKS Cluster to be created, then proceed to the next step.

---

### 3. Use AWS console create EKS cluster Node Group:

(1) Navigate to EKS Console:

> EKS / Clusters / `<Your-Cluster>` / Compute / Node groups > `Add node group`

(2) Fill in the details:

- **Name:** `<Your-AWS-EKS-Node-Group-Name>`
- **Node IAM role:** `<Your-AWS-EKS-Node-Group-Role-Name>`

> next

(3) Set compute and scaling configuration:

### Example:

- **Node group compute configuration:**

  - AMI type: `Amazon Linux 2 (AL2_x86_64)`
  - Capacity type: `On-Demand`
  - Instance types: `t3.medium`
  - Disk size: `20 GiB`

- **Node group scaling configuration:**

  - Desired size: `2 nodes`
  - Minimum size size: `2 nodes`
  - Maximum size: `2 nodes`

- **Node group update configuration:**

  - Maximum unavailable: `Number`
    - Value: `1 node`

> next

(4) Specify networking:

- **Node group network configuration:**

  - Subnets:
    - `<Your-Vpc-Subnet-1>`
    - `<Your-Vpc-Subnet-2>`

> Next

(5) Review and create:

> Create

(6) Wait for Node Group to be created, then proceed to the next step.

---

### 4. Use the terminal (in the `"AWS_EKS"` directory) to connect to the cluster by running the following commands:

```bash
./connect_to_cluster.sh
```

- This will open the file using the vim editor. \
  If the file is not empty, clean up all contents, \
  save, and quit using the vim editor. \
  \
  Next, it will automatically write the new cluster data to the file. \
  Once all is done, simply quit the vim editor.

---

### 5. Use terminal add all nodes labels for deployment:

```bash
kubectl get nodes
kubectl describe node <my-node> | grep zone
kubectl label nodes <my-node> zone=<my-zone>
```

- Replace `<my-node>` to your node name and `<my-zone>` to your node zone
  (ex. us-east-1`a`).

---

### 6. Use terminal (in `"AWS_EKS"` directory) to create EKS cluster by following commands:

```bash
./AWS_EBS_CSI_setup.sh
```

# `Successfully completing all configurations!!!`

---

## @@@ Use terminal to updating the Amazon EBS CSI driver as an Amazon EKS add-on:

Open terminal and execute following commands:

step1:

```bash
eksctl get addon --name aws-ebs-csi-driver --cluster <my-cluster>
```

step2:

```bash
eksctl update addon --name aws-ebs-csi-driver --version <VERSION> --cluster <my-cluster> \
--service-account-role-arn arn:aws:iam::<my_account_id>:role/AmazonEKS_EBS_CSI_DriverRole --force
```

Please note that you need to replace `<my-cluster>`, `<VERSION>`, and `<my_account_id>` with your specific values before executing these commands.

---

## @@@ Use terminal(in `"AWS_EKS"` directory) to removing the Amazon EBS CSI add-on by following commands:

    ./AWS_EBS_CSI_delete.sh

---

## `Troubleshooting:`

## ### failed to provision volume with StorageClass "ebs-sc": rpc error: code = Internal desc = Could not create volume "pvc-a4270f39-0970-4f93-a0a9-8e63227204ee": could not create volume in EC2: WebIdentityErr: failed to retrieve credentials caused by: AccessDenied: Not authorized to perform sts:AssumeRoleWithWebIdentity status code: 403, request id: 9141ad19-dba9-4ee6-aa9f-de61bfc2c0e7

## ### Warning FailedScheduling 83s default-scheduler 0/2 nodes are available: pod has unbound immediate PersistentVolumeClaims. preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling..

## `[Fixed]` Make sure your AmazonEKS_EBS_CSI_DriverRole trust policy is correctly:

> IAM / Roles / AmazonEKS_EBS_CSI_DriverRole / Trust relationships > `Trusted entities`

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "<Your-AWS-OIDC-Identity-Provider-ARN>"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "<Your-AWS-OIDC-Identity-Provider>:aud": "sts.amazonaws.com",
          "<Your-AWS-OIDC-Identity-Provider>:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
```

- Make sure `<Your-AWS-Identity-OICD-Provider-ARN>` and `<Your-AWS-OIDC-Identity-Provider>` is the same values from your aws oidc identity providers.

Get into AWS console and check out:

> IAM / Identity providers / `<Your-AWS-OIDC-identity-Provider>` / `<Provider>` & `<ARN>`

---

By Leon Chiang 08/12/2023
