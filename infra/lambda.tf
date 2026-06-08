/*
Notes:
 . A Lambda function is similar to a security alarm. 
 . It's code that sits dormant(not in use), and only runs when something triggers it.
 . For this project, Lambda acts as a responder. 
 . When the honeytoken is used, the alarm will fire, and Lambda awakens to log the details


 . SNS is similar to a text message
 . When a "topic" is created, its like opening a group chat
 . Anyone can send a message to it, and everyone subscribed receives it
 . Since CloudWatch can't directly speak to Lambda, SNS acts as the middleman
 . This is because SNS creates a topic and Lambda is subscribed to it.
 . Therefore it will receive the message/alert details
*/

#Create a SNS topic (Groupchat that cloudwatch sends to)
resource "aws_sns_topic" "honeytoken_alert" {
  name = "honeytoken-alerts"
}

#reads/plans a trust policy for a lambda execution role
#Lets Lambda wear the role badge
#this approves lambda the service to assume the role
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]

    principals {
      type = "Service"
      identifiers = [ "lambda.amazonaws.com" ]
    }
  }
}

#create the role for lambda execution(the badge itself)
resource "aws_iam_role" "lambda_exec" {
  name = "honeytoken-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

#attach the role policy (give the badge access to write its own log to cloudwatch)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
 role = aws_iam_role.lambda_exec.name
 policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#reads/plans package & deploy the function
#Zips up the "lambda/" folder so AWS can receive it
data "archive_file" "lambda_zip" {
  type = "zip"
  source_dir = "${path.module}/../lambda"
  output_path = "${path.module}/../lambda.zip"
}

#creates lambda function to deploy function
resource "aws_lambda_function" "honeytoken_alert" {
  role = aws_iam_role.lambda_exec.arn
  function_name = "honeytoken-alert"
  filename = data.archive_file.lambda_zip.output_path
  handler = "index.handler"
  runtime = "nodejs20.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

#passes the dynamodb table to lambda
  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.honeytoken_incidents.name
    }
  }
}

#creates lambda permission to allow sns to invoke lambda
resource "aws_lambda_permission" "sns_invoke" {
  statement_id = "AllowSNSInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.honeytoken_alert.function_name
  principal = "sns.amazonaws.com"
  source_arn = aws_sns_topic.honeytoken_alert.arn
}

#subscribe lambda to the topic
#signs lambda to the group chat to receive the messages
resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.honeytoken_alert.arn
  protocol = "lambda"
  endpoint = aws_lambda_function.honeytoken_alert.arn
}

#adds an email subscription
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.honeytoken_alert.arn
  protocol = "email"
  endpoint = var.alert_email
}

