# ─── Terraform Configuration ─────────────────────────────────────────────────
# Infrastructure as Code for Reddit Clone Application
# Provider: AWS (EKS cluster + VPC + supporting resources)
# ─────────────────────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "reddit-clone-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "reddit-clone"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# ─── VPC ─────────────────────────────────────────────────────────────────────
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "${var.project_name}-vpc-${var.environment}"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway   = true
  single_nat_gateway   = var.environment == "dev" ? true : false
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# ─── EKS Cluster ─────────────────────────────────────────────────────────────
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = "1.28"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      name           = "default-node-group"
      instance_types = var.environment == "dev" ? ["t3.medium"] : ["t3.large"]
      min_size       = var.environment == "dev" ? 1 : 2
      max_size       = var.environment == "dev" ? 2 : 5
      desired_size   = var.environment == "dev" ? 1 : 2

      labels = {
        Environment = var.environment
      }
    }
  }

  # Enable IRSA (IAM Roles for Service Accounts)
  enable_irsa = true
}

# ─── ECR Repository ─────────────────────────────────────────────────────────
resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-${var.environment}"
  image_tag_mutability = "MUTABLE"
  force_delete         = var.environment == "dev" ? true : false

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

# ─── Security Group for ALB ──────────────────────────────────────────────────
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-alb-${var.environment}"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
