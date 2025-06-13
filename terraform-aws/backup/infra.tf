###############################################################################
# 1. (Unchanged) Your existing VPC and EKS modules
###############################################################################

provider "aws" {
  region = var.aws_region
}

locals {
  short_name = substr(var.cluster_name, 0, 7)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "${local.short_name}-vpc"
  cidr = var.cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = ">=20.37.0"

  cluster_name    = local.short_name
  cluster_version = var.eks_cluster_version

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns             = { most_recent = true }
    kube-proxy          = { most_recent = true }
    vpc-cni             = { most_recent = true }
    aws-ebs-csi-driver  = {
      most_recent = true
      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name             = "${local.short_name}-group-1"
      instance_types   = [var.eks_vm_size]
      capacity_type    = "ON_DEMAND"
      min_size         = 1
      max_size         = 3
      desired_size     = 3
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = data.aws_iam_policy.ebs_csi_policy.arn
      }
    }
    two = {
      name             = "${local.short_name}-group-2"
      instance_types   = [var.eks_vm_size]
      capacity_type    = "ON_DEMAND"
      min_size         = 1
      max_size         = 2
      desired_size     = 1
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = data.aws_iam_policy.ebs_csi_policy.arn
      }
    }
  }
}

###############################################################################
# 2. Pull the CockroachDB PrivateLink service for your cluster
###############################################################################

resource "cockroach_private_endpoint_services" "services" {
  cluster_id = cockroach_cluster.advanced.id
}  
# service_name gives the AWS PrivateLink service name to use when creating the VPC endpoint :contentReference[oaicite:0]{index=0}

###############################################################################
# 3. Security group for the Interface endpoint
###############################################################################
resource "aws_security_group" "crdb_privatelink_sg" {
  name        = "${local.short_name}-crdb-privatelink-sg"
  description = "Allow EKS worker nodes to reach CockroachDB PrivateLink"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "DB traffic from EKS nodes"
    from_port       = 26257
    to_port         = 26257
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  ingress {
    description     = "DB health traffic from EKS nodes"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


###############################################################################
# 4. Create the AWS Interface VPC Endpoint
###############################################################################

resource "aws_vpc_endpoint" "crdb_privatelink" {
  vpc_id             = module.vpc.vpc_id
  service_name       = cockroach_private_endpoint_services.services.services_map[var.aws_region].name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [aws_security_group.crdb_privatelink_sg.id]
  private_dns_enabled = false
}
# Standard Interface Endpoint config :contentReference[oaicite:1]{index=1}

###############################################################################
# 5. Accept the PrivateLink connection in CockroachDB Cloud
###############################################################################

resource "cockroach_private_endpoint_connection" "connection" {
  cluster_id  = cockroach_cluster.advanced.id
  endpoint_id = aws_vpc_endpoint.crdb_privatelink.id
}
# endpoint_id is the AWS VPC Endpoint ID; this resource tells Cockroach Cloud to accept it :contentReference[oaicite:2]{index=2}

data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}
