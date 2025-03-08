# ===============================================================================
# ALB
# ===============================================================================
resource "aws_security_group" "alb" {
  name        = "${local.project}-${local.env}-alb"
  description = "security group for ${local.project}-${local.env} alb"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.project}-${local.env}-alb"
  }
}

resource "aws_security_group_rule" "alb_ingress_443_tcp_internet" {
  security_group_id = aws_security_group.alb.id
  description       = "Internet to ALB"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_egress_8880_8882_tcp_app" {
  security_group_id        = aws_security_group.alb.id
  description              = "ALB to APP"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "8880"
  to_port                  = "8882"
  source_security_group_id = aws_security_group.app.id
}

# ===============================================================================
# APP
# ===============================================================================
resource "aws_security_group" "app" {
  name        = "${local.project}-${local.env}-app"
  description = "security group for ${local.project}-${local.env} app"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.project}-${local.env}-app"
  }
}

# TODO: SSH

resource "aws_security_group_rule" "app_ingress_8880_8882_tcp_alb" {
  security_group_id        = aws_security_group.app.id
  description              = "ALB to APP"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8880
  to_port                  = 8882
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "app_egress_8880_8882_tcp_app" {
  security_group_id = aws_security_group.app.id
  description       = "APP outbound to Internet"
  type              = "egress"
  protocol          = "-1" # すべてのプロトコル
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}
