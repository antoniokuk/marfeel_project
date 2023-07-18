resource "aws_iam_role" "nodes" {
  name = "marfeel-eks-nodes"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "nodes-marfeelEksNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/marfeelEksNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-marfeelEksCNIPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/marfeelEksCNIPolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-marfeelEksContainersReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/marfeelEksContainersReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_eks_node_group" "private-nodes" {
  cluster_name     = aws_eks_cluster.marfeel_cluster
  node_group_name  = "private-nodes"
  node_role_arn    = aws_iam_role.nodes.arn

  subnet_ids        = [
    aws_subnet.private-us-east-1b.id,
    aws_subnet.private-us-east-1f.id
  ]

  capacity_type    = "ON_DEMAND"
  instance_types   = ["m5.large"]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }
}