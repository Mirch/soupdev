resource "aws_iam_role" "get_profile" {
  assume_role_policy = data.aws_iam_policy_document.get_profile_assume_policy.json
}

data "aws_iam_policy_document" "get_profile_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "get_profile_policy_document" {
  statement {
    actions = [
      "dynamodb:Query",
    ]
    resources = [
      aws_dynamodb_table.users.arn,
      "${aws_dynamodb_table.users.arn}/*",
    ]
  }
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/*"
    ]
  }
}

resource "aws_iam_policy" "get_profile_policy" {
  name   = "get_profile_policy"
  policy = data.aws_iam_policy_document.get_profile_policy_document.json
}

resource "aws_iam_role_policy_attachment" "get_profile_policy_attachment" {
  role       = aws_iam_role.get_profile.name
  policy_arn = aws_iam_policy.get_profile_policy.arn
}