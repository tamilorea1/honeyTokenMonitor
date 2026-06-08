#Create dynamodb table to store logs/incidents of someone using the honeytoken
resource "aws_dynamodb_table" "honeytoken_incidents" {
  name = "honeytoken-incidents"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "incident_id"

  attribute {
    name = "incident_id"
    type = "S"
  }
}

#reads/plan the policy to give lambda permission to write to the table
data "aws_iam_policy_document" "lambda_dynamodb_policy" {
  statement {
    effect = "Allow"
    actions = [ "dynamodb:PutItem" ]
    resources = [ aws_dynamodb_table.honeytoken_incidents.arn ]
  }
}

#create the policy for lambda to write the logs to the table
#as well as attach it to the lambda role
resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "lambda-dynamodb-role"
  policy = data.aws_iam_policy_document.lambda_dynamodb_policy.json
  role = aws_iam_role.lambda_exec.id
}