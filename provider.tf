provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_bp.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_bp.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_bp.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_bp.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks_bp.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_bp.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }
  }

  # Uncomment this code and run terraform init to get the local state transferred to S3
  backend "s3" {
    bucket  = "aggregator-infra-state"
    key     = "terraform.tfstate"
    region  = local.region
    encrypt = true
  }
}

