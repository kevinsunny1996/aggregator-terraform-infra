data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecr_access_policy" {
  version = "2008-10-17"

  statement {
    sid = "New Policy"
    
    actions = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeRepositories",
        "ecr:GetRepositoryPolicy",
        "ecr:ListImages",
        "ecr:DeleteRepository",
        "ecr:BatchDeleteImage",
        "ecr:SetRepositoryPolicy",
        "ecr:DeleteRepositoryPolicy"
    ]

    principals {
      type = "AWS"

      identifiers = formatlist("arn:aws:iam::%s:user/terraform-user", data.aws_caller_identity.current.account_id)
    }
  }
}


resource "aws_ecr_repository" "agg_repo" {
  name = "${var.project_name}"
}

resource "aws_ecr_repository_policy" "agg_repo_policy" {
  repository = aws_ecr_repository.agg_repo.name

  policy = data.aws_iam_policy_document.ecr_access_policy.json
}

resource "aws_ecr_repository" "mlflow_server" {
  name = "${var.ml_artifact_project_name}"
}

resource "aws_ecr_repository_policy" "mlflow_server_policy" {
  repository = aws_ecr_repository.mlflow_server.name

  policy = data.aws_iam_policy_document.ecr_access_policy.json
}

resource "aws_ecr_repository" "airflow_server" {
  name = "${var.orch_project_name}"
}

resource "aws_ecr_repository_policy" "airflow_server_policy" {
  repository = aws_ecr_repository.airflow_server.name

  policy = data.aws_iam_policy_document.ecr_access_policy.json
}