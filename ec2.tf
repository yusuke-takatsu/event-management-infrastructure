data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-minimal-kernel-default-arm64"
}

resource "aws_instance" "basition_al2023" {
  ami = data.aws_ssm_parameter.al2023.value
  instance_type = "t2.micro"
}
