resource "aws_instance" "basition" {
  ami = data.aws_ssm_parameter.al2023.value
  # iam_instance_profile = aws_iam_instance_profile.bastion_instance
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.bastion.key_name
  associate_public_ip_address = true
  disable_api_stop            = true
  disable_api_termination     = true
  monitoring                  = true
  subnet_id                   = aws_subnet.public[local.availability_zones[0]].id

  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]

  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    volume_size = "8"
  }

  lifecycle {
    ignore_changes = [
      ami,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-bastion"
  }
}

resource "aws_eip" "bastion" {
  instance = aws_instance.basition.id
  domain   = "vpc"

  tags = {
    Name = "${local.project}-${local.env}-bastion"
  }
}

resource "aws_key_pair" "bastion" {
  key_name   = "${local.project}-${local.env}-bastion"
  public_key = var.key_pair_pub
}

data "aws_ssm_parameter" "bastion" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-minimal-kernel-default-arm64"
}
