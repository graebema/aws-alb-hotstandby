###### PREREQUISITE:  the zone exists and DNS delegation has been setup
#                     otherwise this code will loop until timeout
#

data "aws_route53_zone" "zone" {
  name         = var.zone
  private_zone = false
}
resource "aws_route53_record" "alias" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.fqdn
  type    = "A"
  alias {
    evaluate_target_health = false
    name                   = var.target
    zone_id                = var.target_zone_id
  }
  allow_overwrite = true
}
