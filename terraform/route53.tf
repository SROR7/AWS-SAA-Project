# Route 53 Hosted Zone
resource "aws_route53_zone" "task_zone" {
  name = "example.com"

  tags = {
    Name        = "task-route53"
    Environment = "Production"
  }
}


# ACM Certificate for CloudFront
resource "aws_acm_certificate" "task_certificate" {
  domain_name       = "example.com"
  validation_method = "DNS"

  subject_alternative_names = [
    "www.example.com"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "task-cloudfront-certificate"
  }
}


# DNS Validation Records
resource "aws_route53_record" "task_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.task_certificate.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.task_zone.zone_id

  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}


# Validate ACM Certificate
resource "aws_acm_certificate_validation" "task_certificate_validation" {
  certificate_arn = aws_acm_certificate.task_certificate.arn

  validation_record_fqdns = [
    for record in aws_route53_record.task_cert_validation :
    record.fqdn
  ]
}


# Root Domain - A Record
resource "aws_route53_record" "task_root_a" {
  zone_id = aws_route53_zone.task_zone.zone_id
  name    = "example.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.task_cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.task_cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}


# WWW - A Record
resource "aws_route53_record" "task_www_a" {
  zone_id = aws_route53_zone.task_zone.zone_id
  name    = "www.example.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.task_cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.task_cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}


# Root Domain - AAAA Record (IPv6)
resource "aws_route53_record" "task_root_aaaa" {
  zone_id = aws_route53_zone.task_zone.zone_id
  name    = "example.com"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.task_cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.task_cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}


# WWW - AAAA Record (IPv6)
resource "aws_route53_record" "task_www_aaaa" {
  zone_id = aws_route53_zone.task_zone.zone_id
  name    = "www.example.com"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.task_cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.task_cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}