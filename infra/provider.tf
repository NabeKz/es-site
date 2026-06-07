terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.5"
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-1"
}
