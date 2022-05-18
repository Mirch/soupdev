output "client_bucket" {
  value = aws_s3_bucket.soupdev-client.bucket
}

output "domain" {
  value = aws_s3_bucket_website_configuration.soupdev-client.website_endpoint
}