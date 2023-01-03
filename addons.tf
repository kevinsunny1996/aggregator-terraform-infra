# Source module referred from - https://github.com/aws-ia/terraform-aws-eks-blueprints
module "eks_bp_k8s_addon" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.19.0"

  # EKS cluster details 
  eks_cluster_id       = module.eks_bp.eks_cluster_id
  eks_cluster_endpoint = module.eks_bp.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_bp.oidc_provider
  eks_cluster_version  = module.eks_bp.eks_cluster_version

  # EKS addons
  enable_amazon_eks_vpc_cni    = true
  enable_amazon_eks_coredns    = true
  enable_amazon_eks_kube_proxy = true

  enable_metrics_server                = true
  enable_cluster_autoscaler            = true
  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_aws_efs_csi_driver            = true
  enable_aws_for_fluentbit             = true
  enable_aws_load_balancer_controller  = true
  enable_prometheus                    = true

  # Apache airflow addon with custom config
  enable_airflow = true
  airflow_helm_config = {
    name             = local.airflow_name
    chart            = local.airflow_name
    version          = "https://airflow.apache.org"
    version          = "1.7.0"
    namespace        = module.airflow_irsa.namespace
    create_namespace = false
    timeout          = 360
    wait             = false
    description      = "Apache Airflow Helm Chart Deployment configuration"
    values = [templatefile("${path.module}/values.yaml", {
      # Airflow Postgres RDS config
      airflow_db_user = local.airflow_name
      airflow_db_name = module.db.db_instance_name
      # Get the first entry from the connection string name of PG RDS instance
      airflow_db_host = element(split(":", module.db.db_instance_endpoint), 0)
      # S3 bucket for storing logs
      s3_bucket_name          = module.airflow_s3_bucket.s3_bucket_id
      webserver_secret_name   = local.airflow_webserver_secret_name
      airflow_service_account = local.airflow_service_account
      efs_pvc                 = local.efs_pvc
    })]

    set_sensitive = [
      {
        name  = "data.metadataConnection.pass"
        value = aws_secretsmanager_secret_version.postgres.secret_string
      }
    ]
  }
  tags = local.tags
}