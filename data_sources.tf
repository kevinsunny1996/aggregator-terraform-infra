# -----------------------------------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------------------------------

data "aws_eks_cluster_auth" "this" {
  name = module.eks_bp.eks_cluster_id
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current_caller" {}

data "aws_partition" "this" {}

data "aws_iam_policy_document" "airflow_s3_logs" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${data.aws_partition.current.partition}:s3:::${module.airflow_s3_bucket.s3_bucket_id}"]

    actions = [
      "s3:ListBucket"
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${data.aws_partition.current.partition}:s3:::${module.airflow_s3_bucket.s3_bucket_id}/*"]

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
  }

}