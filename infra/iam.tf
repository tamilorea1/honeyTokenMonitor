resource "aws_iam_user" "decoy_user" {
  #Added this name to make it look legitimate 
  name = var.honeytoken_username

  tags = {
    Purpose = "honeytoken"
  }
}

#reads/constructs something without creating a resource
data "aws_iam_policy_document" "deny_all" {
  statement {
    effect = "Deny"
    actions = ["*"]
    resources = ["*"]
  }
}

#creates the policy by referring to the data block
#also will be in json format
resource "aws_iam_policy" "deny_all" {
  name = "honeytoken-deny-all"
  policy = data.aws_iam_policy_document.deny_all.json
}

#attached the created policy to the decoy user
resource "aws_iam_policy_attachment" "honeytoken_deny" {
  name = "honeytoken-deny-attachment"
  users = [aws_iam_user.decoy_user.name]
  policy_arn = aws_iam_policy.deny_all.arn
}

#creates an access key for our honeytoken
resource "aws_iam_access_key" "honeytoken" {
  user = aws_iam_user.decoy_user.name
}