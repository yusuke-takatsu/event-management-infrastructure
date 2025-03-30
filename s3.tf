# ===============================================================================
# iam_ssh
# ===============================================================================
resource "aws_s3_bucket" "iam_ssh" {
  bucket = "${local.project}-iam-ssh"
}

resource "aws_s3_bucket_public_access_block" "iam_ssh" {
  bucket = aws_s3_bucket.iam_ssh.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "iam_ssh" {
  bucket = aws_s3_bucket.iam_ssh.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "iam_ssh" {
  bucket = aws_s3_bucket.iam_ssh.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "install_iam_ssh" {
  bucket  = aws_s3_bucket.iam_ssh.id
  key     = "install_iam_ssh.sh"
  content = local.install_iam_ssh
  etag    = md5(local.install_iam_ssh)
}

resource "aws_s3_object" "aws_ec2_ssh_conf" {
  bucket  = aws_s3_bucket.iam_ssh.id
  key     = "aws-ec2-ssh.conf"
  content = local.aws_ec2_ssh_conf
  etag    = md5(local.aws_ec2_ssh_conf)
}

locals {
  install_iam_ssh = templatefile(
    "${path.cwd}/files/iam_ssh/install_iam_ssh.sh",
    {
      bucket = aws_s3_bucket.iam_ssh.id
    }
  )
  aws_ec2_ssh_conf = templatefile(
    "${path.cwd}/files/iam_ssh/aws-ec2-ssh.conf",
    {
      project = local.project
    }
  )
}


# ===============================================================================
# bastion
# ===============================================================================
resource "aws_s3_bucket" "bastion" {
  bucket = "${local.project}-${local.env}-bastion-instance"
}

resource "aws_s3_bucket_public_access_block" "bastion" {
  bucket = aws_s3_bucket.bastion.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bastion" {
  bucket = aws_s3_bucket.bastion.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# TODO:log設定追加
# resource "aws_s3_bucket_logging" "bastion" {
# }

# resource "aws_s3_object" "bastion_cloudwatch_agent" {
#   bucket = aws_s3_bucket.bastion.id
#   key = "amazon-cloudwatch-agent.json"
#   content = local.bastion_cloudwatch_agent
#   etag = mb5(local.bastion_cloudwatch_agent)
# }

# locals {
#   bastion_cloudwatch_agent = templatefile(
#     "${path.cwd}/files/bastion/amazon-cloudwatch-agent.json",
#     {
#       log_group_name = aws_cloudwatch_log_group.bastion.name
#     }
#   )
# }
