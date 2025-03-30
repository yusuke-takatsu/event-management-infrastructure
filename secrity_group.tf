resource "aws_security_group" "bastion" {
  name        = "${local.project}-${local.env}-bastion"
  description = "security group for ${local.project}-${local.env}-bastion"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.project}-${local.env}-bastion"
  }
}

resource "aws_security_group_rule" "bastion_egress_443_tcp_https" {
  security_group_id = aws_security_group.bastion.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion_egress_80_tcp_http" {
  security_group_id = aws_security_group.bastion.id
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion_egress_3306_tcp_mysql" {
  security_group_id = aws_security_group.bastion.id
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["172.16.0.0/12"]
}

resource "aws_security_group_rule" "bastion_egress_6379_tcp_redis" {
  security_group_id = aws_security_group.bastion.id
  type              = "egress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  cidr_blocks       = ["172.16.0.0/12"]
}
