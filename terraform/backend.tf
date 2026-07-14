terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    key          = "dev/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "ap-northeast-1"
}