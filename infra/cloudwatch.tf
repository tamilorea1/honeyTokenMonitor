#Create a folder in cloudwatch that stores log events
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name = "/aws/cloudtrail/honeytoken"
  retention_in_days = 90
}

#reads/plans a "trust" policy. Explicitly allows CloudTrail to use this role
data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]

    principals {
      type = "Service"
      identifiers = [ "cloudtrail.amazonaws.com" ]
    }
  }
}

#creates the role 
resource "aws_iam_role" "cloudtrail_cloudwatch" {
  name = "cloudtrail_cloudwatch_role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
}

#reads/plans a "permissions" policy. helps answer "what is the role allowed to do"
#give cloudtrail the actions to create a channel inside the log group to write into & write log entries in the channel
data "aws_iam_policy_document" "cloudtrail_cloudwatch_policy" {
  statement {
    effect = "Allow"
    actions = [ "logs:CreateLogStream", "logs:PutLogEvents" ]
    resources = [ "${aws_cloudwatch_log_group.cloudtrail.arn}:*" ]
  }
}

#creates the permission policy and attaches it to the role
resource "aws_iam_role_policy" "cloudtrail_cloudwatch" {
  name = "cloudtrail-cloudwatch-policy"
  role = aws_iam_role.cloudtrail_cloudwatch.id
  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_policy.json
  
}

#Reads every incoming event
resource "aws_cloudwatch_log_metric_filter" "honeytoken_usage" {
  name = "honeytoken-usage"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern = "{$.userIdentity.userName = \"${var.honeytoken_username}\"}"

  metric_transformation {
    name = "HoneytokenUsage"
    namespace = "HoneytokenMonitor"
    value = "1"
  }
}

#Watches the HoneytokenUsage counter
#Every 5 minutes(300 seconds), if the sum > 0. Alarm switches to ALARM state
resource "aws_cloudwatch_metric_alarm" "honeytoken_usage" {
  alarm_name = "honeytoken-accessed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 1
  metric_name = "HoneytokenUsage"
  namespace = "HoneytokenMonitor"
  period = 300
  statistic = "Sum"
  threshold = 0

  #if no data came in don't trigger false alerts
  treat_missing_data = "notBreaching"
  alarm_description = "Honeytoken credentials were used"

  #attaches alarm action from lambda.tf
  alarm_actions = [ aws_sns_topic.honeytoken_alert.arn ]
}