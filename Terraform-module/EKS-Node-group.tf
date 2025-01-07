data "aws_subnets" "available_subnets" {
  filter {
    name = "tag:name"
    values = [ "private-*" ]
  }
}

resource "aws_eks_cluster" "dev-cluster" {
  name = "dev-cluster"
  role_arn = aws_iam_role.cluster-role.arn
  vpc_config {
    subnet_ids = data.aws_subnets.available_subnets.ids
  }
  depends_on = [ 
    aws_iam_role_policy_attachment.clsuter-AmazonEKSClusterPolicy,  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
    awsaws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController   # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
   ]
}

output "endpoint" {
  value = aws_eks_cluster.dev-cluster.endpoint   #this endpoints are configured in frontend
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.dev-cluster.certificate_authority[0].data
}

resource "aws_eks_node_group" "node-group" {
  cluster_name = aws_eks_cluster.dev-cluster.name
  node_group_name = "dev-node-group"
  node_role_arn = aws_iam_role.worker
  subnet_ids = data.aws_subnets.available_subnets.ids
  capacity_type = "ON_DEMAND"
  disk_size = "8"
  instance_types = ["t2.micro"]
  labels = tomap({env = "dev"})

  scaling_config {
    desired_size = 2
    max_size = 3
    min_size = 1
  }
  update_config {
   max_unavailable = 1 
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKSCNIPolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
   ]

}