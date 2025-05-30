terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

provider "aws" {
  region  = "us-east-1"
  alias   = "virginia"
}

provider "aws" {
  #   profile = "development"
  region = "ap-northeast-2"
  alias = "seoul"
}