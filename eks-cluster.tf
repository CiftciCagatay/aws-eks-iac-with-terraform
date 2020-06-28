resource "aws_iam_role" "demo-cluster" {
    name = "demo-cluster"

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

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSClusterPolicy" {
    policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role        = aws_iam_role.demo-cluster.name
}

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSServicePolicy" {
    policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
    role        = aws_iam_role.demo-cluster.name
}

resource "aws_security_group" "demo-cluster" {
    name        = "demo-cluster"
    description = "Cluster communication with worker nodes"
    vpc_id      = aws_vpc.demo-vpc.id

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "demo-cluster"
    }
}

resource "aws_security_group_rule" "demo-cluster-ingress-workstation-https" {
    cidr_blocks         = [local.workstation-external-cidr]
    description         = "Allow workstation to communicate with the Cluster API Server"
    security_group_id   = aws_security_group.demo-cluster.id
    type                = "ingress"
    protocol            = "tcp"
    from_port           = 443
    to_port             = 443
}

resource "aws_eks_cluster" "demo-cluster" {
    name        = var.cluster-name
    role_arn    = aws_iam_role.demo-cluster.arn

    vpc_config {
        security_group_ids  = [aws_security_group.demo-cluster.id]
        subnet_ids          = aws_subnet.demo-public-subnets[*].id
    }

    depends_on  = [
        aws_iam_role_policy_attachment.demo-cluster-AmazonEKSClusterPolicy,
        aws_iam_role_policy_attachment.demo-cluster-AmazonEKSServicePolicy,
    ]
}