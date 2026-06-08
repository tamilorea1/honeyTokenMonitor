variable "aws_region" {
  description = "The AWS region to deply resources in"
  type = string
  default = "us-east-1" #fallback region if none is provided

}

variable "honeytoken_username" {
  description = "name of our decoy  IAM user"
  type = string
  default = "svc-backup-operator"
}

variable "alert_email" {
  description = "Email address to receive honeytoken alerts"
  type = string
}

# variable "test_user_name" {
#   description = "Name of the practice IAM user"
#   type = string
#   default = "test_user"
# }