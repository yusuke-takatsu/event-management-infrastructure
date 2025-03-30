# ===============================================================================
# Github Actions
# ===============================================================================
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
  client_id_list  = ["sts.amazonaws.com"]
}

output "github_actions_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github_actions.arn
}

# ===============================================================================
# bastion_instance
# ===============================================================================
resource "aws_iam_instance_profile" "bastion_instance" {
  name = "${local.project}-bastion-instance"
  role = aws_iam_role.bastion_instance.name
}

resource "aws_iam_role" "bastion_instance" {
  name               = "${local.project}-bastion-instance"
  assume_role_policy = data.aws_iam_policy_document.bastion_instance_assume.json
}

data "aws_iam_policy_document" "bastion_instance_assume" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "bastion_instance" {
  name   = "${local.project}-bastion-instance"
  policy = data.aws_iam_policy_document.bastion_instance.json
}

data "aws_iam_policy_document" "bastion_instance" {
  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
    ]
    resources = [
      "${aws_s3_bucket.bastion.arn}/*",
      "${aws_s3_bucket.iam_ssh.arn}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = [
      aws_cloudwatch_log_group.bastion.arn,
      "${aws_cloudwatch_log_group.bastion.arn}:log-stream:*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "bastion_instance" {
  role       = aws_iam_role.bastion_instance.id
  policy_arn = aws_iam_policy.bastion_instance.arn
}

resource "aws_iam_role_policy_attachment" "bastion_instance_to_AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.bastion_instance.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

