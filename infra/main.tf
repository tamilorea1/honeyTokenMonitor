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
  region = "us-east-1"
}

resource "aws_s3_bucket" "test" {
  bucket = "test-bucket-tamilorea"
}