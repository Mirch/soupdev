# CREATE PAYMENT
resource "aws_lambda_function" "create_payment_lambda" {
  function_name = "GetProfile"

  source_code_hash = data.archive_file.create_payment_archive.output_base64sha256
  filename         = data.archive_file.create_payment_archive.output_path

  handler = "func"
  runtime = "provided"

  role = aws_iam_role.create_payment.arn

  environment {
    variables = {
      DOMAIN = aws_s3_bucket_website_configuration.suppdev-client.website_endpoint
    }
  }
}

data "archive_file" "create_payment_archive" {
  type = "zip"

  source_file = var.create_payment_bin_path
  output_path = "create_payment.zip"
}

resource "aws_iam_role" "create_payment" {
  assume_role_policy = data.aws_iam_policy_document.create_payment_assume_policy.json
}

data "aws_iam_policy_document" "create_payment_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "create_payment_policy_document" {
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

resource "aws_iam_policy" "create_payment_policy" {
  name   = "create_payment_policy"
  policy = data.aws_iam_policy_document.create_payment_policy_document.json
}

resource "aws_iam_role_policy_attachment" "create_payment_policy_attachment" {
  role       = aws_iam_role.create_payment.name
  policy_arn = aws_iam_policy.create_payment_policy.arn
}
