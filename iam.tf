# ===============================================================================
# Github Actions
# ===============================================================================
resource "aws_iam_role" "github_actions" {
  name               = "${local.project}-github-actions"
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
        aws_iam_openid_connect_provider.github_actions.arn
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

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
  client_id_list  = ["sts.amazonaws.com"]
}
