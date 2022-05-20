resource "aws_s3_bucket" "soupdev-client" {
  bucket = "soupdev-web-client"
}

resource "aws_s3_bucket_website_configuration" "soupdev-client" {
  bucket = aws_s3_bucket.soupdev-client.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_acl" "soupdev-client" {
  bucket = aws_s3_bucket.soupdev-client.id

  acl = "public-read"
}

resource "aws_s3_bucket_policy" "soupdev-client" {
  bucket = aws_s3_bucket.soupdev-client.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.soupdev-client.arn,
          "${aws_s3_bucket.soupdev-client.arn}/*",
        ]
      },
    ]
  })
}
