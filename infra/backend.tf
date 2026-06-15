terraform {
  backend "s3" {
    bucket       = "ec-site-tfstate-716860764656-ap-northeast-1-an"
    key          = "infra/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
