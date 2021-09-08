###### PREREQUISITE:  the zone exists and DNS delegation has been setup
#                     otherwise this code will loop until timeout
#

data "aws_route53_zone" "zone" {
  name         = var.zone
  private_zone = false
}

# acm certificate
resource "aws_acm_certificate" "cert" {
  domain_name               = var.fqdn
  subject_alternative_names = var.san
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = var.tags
}


resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
