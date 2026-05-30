/*
    Let's terraform know what provider
    it needs, alongside the version
*/
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

/*
    Never put access and secret keys here
    Its a security issue
*/
provider "aws" {
  # how to properly call variables for the variables.tf file
  region = var.aws_region 
}

resource "aws_iam_user" "test" {
  # name of our IAM user is 'test_user'
  name = var.test_user_name 
}