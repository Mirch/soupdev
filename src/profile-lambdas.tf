# GET PROFILE
resource "aws_lambda_function" "get_profile_lambda" {
  function_name = "GetProfile"

  source_code_hash = data.archive_file.get_profile_archive.output_base64sha256
  filename         = data.archive_file.get_profile_archive.output_path

  handler = "func"
  runtime = "provided"

  role = aws_iam_role.get_profile.arn
}

data "archive_file" "get_profile_archive" {
  type = "zip"

  source_file = "${var.get_profile_bin_path}"   
  output_path = "get_profile.zip"
}

resource "aws_iam_role" "get_profile" {
  assume_role_policy = data.aws_iam_policy_document.get_profile_role.json
}

data "aws_iam_policy_document" "get_profile_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "get_profile" {
  statement {
    actions = [
      "dynamodb:GetItem",
    ]
    resources = [
      aws_dynamodb_table.users.arn,
    ]
  }
}

resource "aws_iam_policy" "get_profile" {
  name = "GetProfilePolicy"
  description = "IAM Policy to allow Lambda function access to DynamoDB"
  policy = data.aws_iam_policy_document.get_profile.json
}

resource "aws_iam_role_policy_attachment" "GetProfilePolicyAttachment" {
  role       = aws_iam_role.get_profile.name
  policy_arn = aws_iam_policy.get_profile.arn
}
