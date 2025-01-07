data "aws_iam_policy_document" "assume_role"{
    statement {
      effect = "allow"
      principals {
        type = "service"
        identifiers = [eks.amazonaws.com]
      }
      actions = ["sts:AssumeRole"]
    }
}

data "aws_iam_policy_document" "assume_node_role"{
    statement {
      effect = "allow"
      principals {
        type = "service"
        identifiers = [ec2.amazonaws.com]
      }
      actions = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role" "cluster-role" {
  name  = "eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "clsuter-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.cluster-role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
    policy_arn = "arn:aws:iam:aws:policy/AmazonEKSVPCResourceController"
    role = aws_iam_role.cluster-role.name
  
}

resource "aws_iam_role" "worker" {
  name = "eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.assume_node_role
}
resource "aws_iam_role_policy_attachment" "AmazonWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.worker.name
}
resource "aws_iam_role_policy_attachment" "AmazonEKSCNIPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.worker.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.worker.name
}