locals {
  project = "event-management"
  region  = "ap-northeast-1"
  default_tags = {
    Managed     = "terraform"
    project     = local.project
    Environment = local.env
  }
  github_repository_prefix = local.project
  base_domain              = "event-management"
}
