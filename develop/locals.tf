locals {
  env = "develop"
  availability_zones = [
    "ap-northeast-1a",
    "ap-northeast-1c",
  ]
  domain = local.base_domain
}
