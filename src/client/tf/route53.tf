resource "aws_route53_zone" "soupdev" {
  name = "soup.dev"
}

resource "aws_route53_record" "root_domain" {
  zone_id = aws_route53_zone.soupdev.zone_id
  name = "soup.dev"
  type = "A"

  alias {
    name = aws_cloudfront_distribution.soupdev_cf_distribution.domain_name
    zone_id = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
