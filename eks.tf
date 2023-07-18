resource "aws_iam_role" "marfeel" {
    name = "marfee-eks-cluster"

    assume_role_policy = <<POLICY

{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Principal": {
            "Service": "eks.amazonaws.com"
        },
        "Action": "sts.AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_group_policy_attachment" "marfeel-EKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/EKSClusterPolicy"
    group      = "arn:aws:iam::aws:group/marfeel-EKSCluster"
  
}

resource "aws_eks_cluster" "marfeel_cluster" {
    name = "marfeel_cluster"
    role_arn = aws_iam_role.marfeel.arn

    vpc_config {
      
      subnet_ids = [
        aws_subnet.private-us-east-1b,
        aws_subnet.private-us-east-1f
     ]

    }

    depends_on = [ aws_iam_group_policy_attachment.marfeel-EKSClusterPolicy ]
}