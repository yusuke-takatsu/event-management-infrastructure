# ===============================================================================
# Github Actions
# ===============================================================================
data "terraform_remote_state" "project" {
  backend = "s3"
  config = {
    bucket = "event-management-terraform"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${local.project}-${local.env}-github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_actions_role.json
}

# 信頼ポリシー作成
data "aws_iam_policy_document" "github_actions_role" {
  statement {
    effect = "Allow"
    # Webアイデンティティ―（OIDCトークンやSAMLアサーションなど）を利用して、一時的なAWS認証情報（アクセスキーやシークレットキー、セッショントークン）を取得
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        data.terraform_remote_state.project.outputs.github_actions_oidc_provider_arn
      ]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:yusuke-takatsu/${local.github_repository_prefix}:*"
      ]
    }
  }
}

resource "aws_iam_policy" "github_actions" {
  name   = "${local.project}-${local.env}-github-actions"
  policy = data.aws_iam_policy_document.github_actions.json
}

data "aws_iam_policy_document" "github_actions" {
  # ECR ログインに必要
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  # `docker push` に必要
  statement {
    effect = "Allow"
    actions = [
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [
      aws_ecr_repository.app.arn,
      aws_ecr_repository.nginx.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}
