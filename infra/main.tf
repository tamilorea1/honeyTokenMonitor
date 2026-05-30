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

  #Store the .tfstate file in an S3 bucket since it could be a single point of failure (SPOF)
  backend "s3" {
    # Which S3 bucket to store the state in
    bucket = "terraform-state-tamilorea"

    #The path inside that bucket (folder/file path on local machine)
    key = "HoneyTokenMonitor/infra/terraform.tfstate"

    #Where the bucket lives
    #didn't use variable bacuase the backend runs during 'terraform init'. So it doesn't know it exists
    region = "us-east-1"

    #The table that handles locking
    dynamodb_table = "terraform-lock"
    
    #Encrypts the state file at rest (should ALWAYS be done)
    encrypt = true
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

resource "aws_s3_bucket" "bucket_for_tfstate" {
  bucket = "terraform-state-tamilorea"
}

resource "aws_s3_bucket_versioning" "tfstate_versioning" {
  #.id references the bucket 'terraform-state-tamilorea'
  bucket = aws_s3_bucket.bucket_for_tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_lock" {
  name = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"  

  #Primary key, unique identifier for each row
  hash_key = "LockID"

  attribute {
    name = "LockID"

    #S menas String
    type = "S"
  }
}

resource "aws_iam_user" "test" {
  # name of our IAM user is 'test_user'
  name = var.test_user_name 
}

