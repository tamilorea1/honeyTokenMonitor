output "honeytoken_user_arn" {
# ARN is Amazon Resource Name
# This after running terraform apply prints the ARN of the IAM user
  description = "The ARN of the honeytoken IAM user"
  value = aws_iam_user.decoy_user.arn

}

#outputs the access key id
output "honeytoken_access_key_id" {
  description = "The access key ID(not secret)"
  value = aws_iam_access_key.honeytoken.id
}

#WILL NOT output the access key in terminal since its sensitive
output "honeytoken_access_key" {
  description = "The secret access key - stored securely"
  value = aws_iam_access_key.honeytoken.secret
  sensitive = true
}