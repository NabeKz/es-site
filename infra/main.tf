resource "aws_ecr_repository" "backend" {
  name = "ec-site-backend"
  force_delete = true
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
