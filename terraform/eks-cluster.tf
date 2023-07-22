resource "aws_iam_role" "terraform-eks-cluster" {
  name = "terraform-eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "terraform-eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.terraform-eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "terraform-eks-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.terraform-eks-cluster.name
}

resource "aws_security_group" "terraform-eks-cluster-sg" {
  name        = "terraform-eks-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.terraform-eks-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-sg"
  }
}

resource "aws_security_group_rule" "terraform-eks-cluster-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"] // local.workstation-external-cidr
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.terraform-eks-cluster-sg.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "terraform-eks-cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.terraform-eks-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.terraform-eks-cluster-sg.id]
    subnet_ids         = aws_subnet.terraform-eks-public-subnet[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.terraform-eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.terraform-eks-cluster-AmazonEKSVPCResourceController,
  ]
}
