resource "aws_acm_certificate" "soupdev" {
  domain_name       = "soup.dev"
  validation_method = "DNS"
}

resource "aws_route53_zone" "soupdev" {
  name = "soup.dev"
}

resource "aws_route53_record" "root_domain" {
  for_each = {
    for dvo in aws_acm_certificate.soupdev.domain_validation_options : dvo.domain_name => {
      name   = replace(dvo.resource_record_name, "/\\.$/", "")
      record = replace(dvo.resource_record_value, "/\\.$/", "")
      type   = dvo.resource_record_type
    }
  }
  name    = each.value.name
  type    = each.value.type
  zone_id = aws_route53_zone.soupdev.zone_id
  records = [each.value.record]

  alias {
    name                   = aws_cloudfront_distribution.soupdev_cf_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.soupdev_cf_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate_validation" "soupdev" {
  certificate_arn         = aws_acm_certificate.soupdev.arn
  validation_record_fqdns = [for record in aws_route53_record.root_domain : record.fqdn]
}
