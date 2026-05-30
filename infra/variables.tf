variable "aws_region" {
  description = "The AWS region to deply resources in"
  type = string
  default = "us-east-1" #fallback region if none is provided

}

variable "test_user_name" {
  description = "Name of the practice IAM user"
  type = string
  default = "test_user"
}