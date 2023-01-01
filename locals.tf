locals {
  name   = var.project_name
  region = var.region

  vpc_cidr                      = var.vpc_cidr
  azs                           = slice(data.aws_availbility_zones.names, 0, 2)
  airflow_name                  = "airflow"
  airflow_service_account       = "airflow-webserver-sa"
  airflow_webserver_secret_name = "airflow-webserver-secret-key"
  efs_storage_class             = "efs-sc"
  efs_pvc                       = "airflowdags-pvc"
  vpc_endpoints                 = ["autoscaling", "ecr.api", "ecr.dkr", "ec2", "ec2messages", "elasticloadbalancing", "sts", "kms", "logs", "ssm", "ssmmessages"]

  tags = {
    Blueprint = local.name
  }
}