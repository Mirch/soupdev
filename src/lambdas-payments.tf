# CREATE PAYMENT
resource "aws_lambda_function" "create_payment_lambda" {
  function_name = "CreatePayment"

  source_code_hash = data.archive_file.create_payment_archive.output_base64sha256
  filename         = data.archive_file.create_payment_archive.output_path

  handler = "func"
  runtime = "provided"

  role = aws_iam_role.create_payment.arn

  environment {
    variables = {
      PAYMENTS_TABLE_NAME = aws_dynamodb_table.payments.name
      DOMAIN              = aws_s3_bucket_website_configuration.suppdev-client.website_endpoint
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
      "dynamodb:PutItem",
    ]
    resources = [
      aws_dynamodb_table.payments.arn,
      "${aws_dynamodb_table.payments.arn}/*",
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

resource "aws_iam_policy" "create_payment_policy" {
  name   = "create_payment_policy"
  policy = data.aws_iam_policy_document.create_payment_policy_document.json
}

resource "aws_iam_role_policy_attachment" "create_payment_policy_attachment" {
  role       = aws_iam_role.create_payment.name
  policy_arn = aws_iam_policy.create_payment_policy.arn
}

# LOG PAYMENT

resource "aws_lambda_function" "log_payment_lambda" {
  function_name = "LogPayment"

  source_code_hash = data.archive_file.log_payment_archive.output_base64sha256
  filename         = data.archive_file.log_payment_archive.output_path

  handler = "func"
  runtime = "provided"

  role = aws_iam_role.log_payment.arn

  environment {
    variables = {
      PAYMENTS_TABLE_NAME   = aws_dynamodb_table.payments.name
      ORDER_ID_INDEX_NAME   = "PaymentsOrderIdIndex"
      STRIPE_WEBHOOK_SECRET = stripe_webhook_endpoint.successful_payments.secret
    }
  }
}

data "archive_file" "log_payment_archive" {
  type = "zip"

  source_file = var.log_payment_bin_path
  output_path = "log_payment.zip"
}

resource "aws_iam_role" "log_payment" {
  assume_role_policy = data.aws_iam_policy_document.log_payment_assume_policy.json
}

data "aws_iam_policy_document" "log_payment_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "log_payment_policy_document" {
  statement {
    actions = [
      "dynamodb:UpdateItem",
    ]
    resources = [
      aws_dynamodb_table.payments.arn,
    ]
  }
  statement {
    actions = [
      "dynamodb:GetItem",
    ]
    resources = [
      aws_dynamodb_table.payments.arn,
      "${aws_dynamodb_table.payments.arn}/*",
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

resource "aws_iam_policy" "log_payment_policy" {
  name   = "log_payment_policy"
  policy = data.aws_iam_policy_document.log_payment_policy_document.json
}

resource "aws_iam_role_policy_attachment" "log_payment_policy_attachment" {
  role       = aws_iam_role.log_payment.name
  policy_arn = aws_iam_policy.log_payment_policy.arn
}


# GET PAYMENTS

resource "aws_lambda_function" "get_payments_lambda" {
  function_name = "GetPayments"

  source_code_hash = data.archive_file.get_payments_archive.output_base64sha256
  filename         = data.archive_file.get_payments_archive.output_path

  handler = "func"
  runtime = "provided"

  role = aws_iam_role.get_payments.arn

  environment {
    variables = {
      PAYMENTS_TABLE_NAME = aws_dynamodb_table.payments.name
      TO_INDEX_NAME       = "PaymentsToIndex"
    }
  }
}

data "archive_file" "get_payments_archive" {
  type = "zip"

  source_file = var.get_payments_bin_path
  output_path = "get_payments.zip"
}

resource "aws_iam_role" "get_payments" {
  assume_role_policy = data.aws_iam_policy_document.get_payments_assume_policy.json
}

data "aws_iam_policy_document" "get_payments_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "get_payments_policy_document" {
  statement {
    actions = [
      "dynamodb:Query",
    ]
    resources = [
      aws_dynamodb_table.payments.arn,
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

resource "aws_iam_policy" "get_payments_policy" {
  name   = "get_payments_policy"
  policy = data.aws_iam_policy_document.get_payments_policy_document.json
}

resource "aws_iam_role_policy_attachment" "get_payments_policy_attachment" {
  role       = aws_iam_role.get_payments.name
  policy_arn = aws_iam_policy.get_payments_policy.arn
}
