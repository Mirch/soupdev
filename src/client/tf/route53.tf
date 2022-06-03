resource "aws_acm_certificate" "soupdev_cert" {
  domain       = "soup.dev"
}

resource "aws_route53_zone" "soupdev" {
  name = "soup.dev"
}

resource "aws_route53_record" "root_domain" {
  for_each = {
    for dvo in aws_acm_certificate.soupdev_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  
  zone_id = aws_route53_zone.soupdev.zone_id
  name = "soup.dev"
  type = "A"

  alias {
    name = aws_cloudfront_distribution.soupdev_cf_distribution.domain_name
    zone_id = aws_cloudfront_distribution.soupdev_cf_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate_validation" "soupdev" {
  certificate_arn         = aws_acm_certificate.soupdev_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.root_domain : record.fqdn]
}
