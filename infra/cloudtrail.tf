#fetches the AWS account ID
#it doesn't take any arguments
data "aws_caller_identity" "current" {}

#The S3 bucket our logs will be written to
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "cloudtrail-logs-tamilorea"
  force_destroy = true
}

#reads/plans the policy to allow cloudtrail permission to write to it
data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  statement {
    sid = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [ "cloudtrail.amazonaws.com" ]
    }

    actions = [ "s3:GetBucketAcl" ]
    resources = [ aws_s3_bucket.cloudtrail_logs.arn ]
  }

  statement {
    sid = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [ "cloudtrail.amazonaws.com" ]
    }

    actions = ["s3:PutObject"]
    resources = [ "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*" ]

    condition {
      test = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [ "bucket-owner-full-control" ]
    }
  }

}

#creates the cloudtrail policy and referencing its respective policy and bucket
resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket_policy.json
}

#create the cloudtrail resource
resource "aws_cloudtrail" "honeytoken" {
  name = "honeytoken-trail"
  s3_bucket_name = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail = true
  enable_logging = true

  #cloudtrail need to see the bucket policy before it begins enabling
  depends_on = [ aws_s3_bucket_policy.cloudtrail_logs ]
}