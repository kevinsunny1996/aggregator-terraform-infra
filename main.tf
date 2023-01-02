# -----------------------------------------------------------------------------------------------------------------------
# EKS Blueprints
# -----------------------------------------------------------------------------------------------------------------------
module "eks_bp" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.19.0"

  cluster_name    = local.name
  cluster_version = var.eks_cluster_version

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  node_security_group_additional_rules = {
    # Extend node to node security group rules , required and / or recommended for K8s Addons.
    ingress_self_all = {
      description = "Node to node all ports/protocols for incoming traffic"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    # Outbound traffic for Node groups
    egress_all = {
      description      = "Node to node all ports/protocols for outgoing traffic"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    # Allows Control Plane nodes to connect with worker nodes on all ports. Can be tailored to suit specific addons.
    # Karpenter - 8443, metrics-server - 4443 etc.
    ingress_cluster_to_all_nodes_traffic = {
      description                   = "Cluster API to node all ports/protocols for outgoing traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  managed_node_groups = {
    # Core node group for managing critical addons
    mng1 = {
      node_group_name = "core-node-group"
      subnet_ids      = module.vpc.private_subnets

      instance_types = ["t2.micro"]
      ami_type       = "AL2_x86_64"
      capacity_type  = "ON_DEMAND"

      # Free tier gives upto 30 GB of gp2 SSD EBS
      disk      = 30
      disk_type = "gp2"

      max_size               = 8
      min_size               = 2
      desired_size           = 4
      create_launch_template = true
      launch_template_os     = "amazonlinux2eks"

      update_config = [{
        max_unavailable_percentage = 50
      }]

      k8s_labels = {
        Environment   = "prod"
        Zone          = "prod-setup"
        WorkerType    = "ON_DEMAND"
        NodeGroupType = "core"
      }

      additional_tags = {
        Name                                                             = "core-node-grp"
        subnet_type                                                      = "private"
        "k8s.io/cluster-autoscaler/node-template/label/arch"             = "x86"
        "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/os" = "linux"
        "k8s.io/cluster-autoscaler/node-template/label/noderole"         = "core"
        "k8s.io/cluster-autoscaler/node-template/label/node-lifecycle"   = "on-demand"
        "k8s.io/cluster-autoscaler/${local.name}"                        = "owned"
        "k8s.io/cluster-autoscaler/enabled"                              = "true"
      }
    }
  }

  tags = local.tags

}

# ------------------------------------------------------------------------------------------------------------------
# RDS PG DB setup for Airflow metadata DB
# ------------------------------------------------------------------------------------------------------------------

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~>5.0"

  identifier = local.airflow_name

  engine         = "postgres"
  engine_version = "14.5"
  family         = "postgres14"
  instance_class = "db.m5.large"

  storage_type      = "gp3"
  allocated_storage = 20

  db_name                = local.airflow_name
  username               = local.airflow_name
  create_random_password = false
  password               = sensitive(aws_secretsmanager_secret_version.postgres.secret_string)
  port                   = 5432

  multi_az               = false
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]

  deletion_protection = false

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = local.tags

}

module "airflow_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "airflow-logs-${data.aws_caller_identity.current_caller.account_id}"
  acl    = "private"

  force_destroy = true

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = local.tags

}

# --------------------------------------------------------------------------------------------------
# Airflow metadata DB master password
# --------------------------------------------------------------------------------------------------
resource "random_password" "postgres" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "postgres" {
  name                    = "postgres"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "postgres" {
  secret_id     = aws_secretsmanager_secret.postgres.id
  secret_string = random_password.postgres.result
}

# --------------------------------------------------------------------------------------------------
# Airflow Webserver Secret
# --------------------------------------------------------------------------------------------------
resource "random_id" "airflow_webserver" {
  byte_length = 16
}

resource "aws_secretsmanager_secret" "airflow_webserver" {
  name                    = "airflow_webserver_secret_key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "airflow_webserver" {
  secret_id     = aws_secretsmanager_secret.airflow_webserver.id
  secret_string = random_id.airflow_webserver.hex
}

# --------------------------------------------------------------------------------------------------
# Airflow Webserver Secret Key
# --------------------------------------------------------------------------------------------------
resource "kubectl_manifest" "airflow_webserver" {
  sensitive_fields = [
    "data.webserver-secret-key"
  ]

  yaml_body = <<-YAML
apiVersion: v1
kind: Secret
metadata:
    name: ${local.airflow_webserver_secret_name}
    namespace: ${local.airflow_irsa.namespace}
type: Opaque
data:
    webserver-secret-key: ${base64encode(aws_secretsmanager_secret_version.airflow_webserver.secret_string)}
YAML
}

# --------------------------------------------------------------------------------------------------
# Managing DAGs with EFS GitSync - EFS Storage Class
# --------------------------------------------------------------------------------------------------
resource "kubectl_manifest" "efs_sc" {
  yaml_body = <<-YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
    name: ${local.efs_storage_class}
provisioner: efs.csi.aws.com
parameters: 
    provisioningMode: efs-ap
    fileSystemId: ${aws_efs_file_system.efs.id}
    directoryPerms: "700"
    gidRangeStart: "1000"
    gidRangeEnd: "2000"
YAML

  depends_on = [
    module.eks_bp.eks_cluster_id
  ]
}

# --------------------------------------------------------------------------------------------------
# Persistent Volume Claim for EFS
# --------------------------------------------------------------------------------------------------
resource "kubectl_manifest" "efs_pvc" {
  yaml_body = <<-YAML
apiVersion: storage.k8s.io/v1
kind: PersistentVolumeClaim
metadata:
    name: ${local.efs_pvc}
    namespace: ${module.airflow_irsa.namespace}
spec:
    accessModes: 
        - ReadWriteMany
    storageClassName: ${local.efs_storage_class}
    resources:
        requests:
            storage: 5Gi
YAML

  depends_on = [
    kubectl_manifest.efs_sc
  ]
}

# --------------------------------------------------------------------------------------------------
# EFS for Airflow DAGs
# --------------------------------------------------------------------------------------------------
resource "aws_efs_file_system" "efs" {
  creation_token = "efs"
  encrypted      = true

  tags = local.tags
}

resource "aws_efs_mount_target" "efs_mt" {
  count = length(module.vpc.private_subnets)

  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = module.vpc.private_subnets[count.index]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  name        = "${local.name}-efs"
  description = "Allow Inbound NFS traffic to Private subnets in VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    cidr_blocks = [module.vpc.private_subnets_cidr_blocks]
    description = "Allow NFS 2049 / TCP"
    from_port   = 2049
    protocol    = "tcp"
    to_port     = 2049
  }

  tags = local.tags

}

# --------------------------------------------------------------------------------------------------
# IRSA (IAM Role for Service Accounts) for Airflow S3 logging
# --------------------------------------------------------------------------------------------------
module "airflow_irsa" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/irsa?ref=v4.19.0"

  eks_cluster_id             = module.eks_bp.eks_cluster_id
  eks_oidc_provider_arn      = module.eks_bp.eks_oidc_provider_arn
  irsa_iam_policies          = [aws_iam_policy.airflow.arn]
  kubernetes_namespace       = "airflow"
  kubernetes_service_account = local.airflow_service_account
}

# --------------------------------------------------------------------------------------------------
# Create IAM Policy for accessing S3 bucket
# --------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "airflow" {
  description = "IAM Policy for Airflow S3 logs"
  name        = "${local.name}-airflow-irsa"
  policy      = data.aws_iam_policy_document.airflow_s3_logs.json
}

# --------------------------------------------------------------------------------------------------
# PostgresSQL RDS Security Group
# --------------------------------------------------------------------------------------------------
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Inbound rule for PG Database"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [{
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    description = "PostgresSQL access from within VPC"
    cidr_blocks = module.vpc.vpc_cidr_block
  }]

  tags = local.tags

}