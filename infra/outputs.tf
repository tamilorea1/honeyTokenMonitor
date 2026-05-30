output "practice_user_arn" {
# ARN is Amazon Resource Name
# This after running terraform apply prints the ARN of the IAM user
  description = "The ARN of the practice IAM user"
  value = aws_iam_user.test.arn

}