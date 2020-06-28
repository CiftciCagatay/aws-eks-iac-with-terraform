resource "aws_iam_role" "demo-cluster-node" {
    name = "demo-node"

    assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
    POLICY
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKSWorkerNodePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role        = aws_iam_role.demo-cluster-node.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKS_CNI_Policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role        = aws_iam_role.demo-cluster-node.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEC2ContainerRegistryReadOnly" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role        = aws_iam_role.demo-cluster-node.name
}

resource "aws_eks_node_group" "demo-cluster" {
    cluster_name    = aws_eks_cluster.demo-cluster.name
    node_group_name = "demo-nodes"
    node_role_arn   = aws_iam_role.demo-cluster-node.arn
    subnet_ids      = aws_subnet.demo-private-subnets[*].id
    instance_types  = ["t3.small"]

    scaling_config {
        desired_size    = 1
        max_size        = 1
        min_size        = 1
    }

    depends_on = [
        aws_iam_role_policy_attachment.demo-node-AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.demo-node-AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.demo-node-AmazonEC2ContainerRegistryReadOnly,
    ]
}