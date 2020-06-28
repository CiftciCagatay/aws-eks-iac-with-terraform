# AWS EKS Cluster with Terraform

Applied infrastructure as a code pattern for EKS cluster.

Note: If you create these resources you may be charged for them by AWS.

After "terraform apply" command infrastructure represented in visual below is created.

![alt text](https://github.com/CiftciCagatay/aws-eks-iac-with-terraform/blob/master/infra.png "Result infra")

I used public&private subnets pattern. Private subnets for worker nodes, public subnets for Load Balancers and NAT gateways.

I needed NAT gateways so worker nodes could reach to the Internet. Eggress only for security reasons. (TODO: Check eggress only internet gateways)

Saw workstation-external-ip on the internet. It is used to get workstation's IP address and later create a security group to enable access to the API server from that workstation. (Check aws_security_group_rule.demo-cluster-ingress-workstation-https)
