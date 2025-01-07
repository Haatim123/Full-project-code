# This configuration provisions an EFS file system and creates mount targets for each subnet.

#create security group for EFS
resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Security group for EFS"

  ingress {
    from_port   = 2049  # NFS (Network File System)
    to_port     = 2049  # NFS (Network File System)
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Update to restrict access to your VPC CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "EFS Security Group"
    Environment = "Production"
  }
}

# Output private subnets (for debugging or validation)
output "private_subnets" {
  value = data.aws_subnets.private_subnets.ids
}

############################################################################
# create EFS
############################################################################

data "aws_subnet" "private-subnet-ids" { #fetching private subnets dynamically
  filter {
    name = "tag:name"
    values = ["private-*"]    //EFS is attached to private subnet
  }
}
resource "aws_efs_file_system" "efs" {
  creation_token = "my-efs"
  performance_mode = "generalpurpose"
  encrypted = true

  tags = {
    Name = "My-efs"
    environment = var.environment
  }
}

resource "aws_efs_mount_target" "efs_mount_targets" {
  count = length(data.aws_subnet.subnet-ids.ids)  #count of private subnets
  file_system_id = aws_efs_file_system.efs.id
  subnet_id = data.aws_subnet.private-subnet-ids[count.index]  # Attach to private subnets ex:ubnet_id = data.aws_subnet.private-subnet-ids[0]
  security_groups = [aws_security_group.efs_sg.id] # EFS Security Group
} 

############################################################################
# Kubernetes Integration for EFS
############################################################################
# To use EFS as shared storage in Kubernetes, you'll need the EFS CSI driver.
# Below are the steps and corresponding YAML manifests for mounting EFS.

# Prerequisite: Install EFS CSI Driver in Your Kubernetes Cluster
# Run the following commands to install the EFS CSI driver:
# kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/ecr/?ref=release-1.4"

# Define the StorageClass:
# Create a StorageClass for the EFS file system:
# YAML:
# apiVersion: storage.k8s.io/v1
# kind: StorageClass
# metadata:
#   name: efs-sc
# provisioner: efs.csi.aws.com

# Apply this configuration:
# kubectl apply -f efs-storageclass.yaml

# Define a PersistentVolume
# Create a PersistentVolume (PV) to reference the EFS file system:
# YAML: 
# apiVersion: v1
# kind: PersistentVolume
# metadata:
#   name: efs-pv
# spec:
#   capacity:
#     storage: 5Gi
#   accessModes:
#     - ReadWriteMany
#   persistentVolumeReclaimPolicy: Retain
#   storageClassName: efs-sc
#   csi:
#     driver: efs.csi.aws.com
#     volumeHandle: <EFS-FILE-SYSTEM-ID> # Replace with your EFS file system ID

# Apply this configuration:
# kubectl apply -f efs-pv.yaml

# Define a PersistentVolumeClaim
# Create a PersistentVolumeClaim (PVC) to use the PersistentVolume:
# YAML:
# apiVersion: v1
# kind: PersistentVolumeClaim
# metadata:
#   name: efs-pvc
# spec:
#   accessModes:
#     - ReadWriteMany
#   resources:
#     requests:
#       storage: 5Gi
#   storageClassName: efs-sc

# Apply this configuration:
# kubectl apply -f efs-pvc.yaml


# Mount the PVC in a Kubernetes Deployment
# Reference the PVC in your Pod or Deployment:
#YAML: 
# apiVersion: apps/v1
# kind: Deployment
# metadata:
#   name: my-app
# spec:
#   replicas: 1
#   selector:
#     matchLabels:
#       app: my-app
#   template:
#     metadata:
#       labels:
#         app: my-app
#     spec:
#       containers:
#       - name: my-app-container
#         image: nginx
#         volumeMounts:
#         - name: efs-storage
#           mountPath: /mnt/efs
#       volumes:
#       - name: efs-storage
#         persistentVolumeClaim:
#           claimName: efs-pvc

# Apply this configuration:
# kubectl apply -f app-deployment.yaml
