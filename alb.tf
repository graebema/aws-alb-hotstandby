# domain validated certificate for alb
module "acm" {
  source = "./modules/acm"
  zone   = var.zone # foo.com
  fqdn   = var.fqdn # service.foo.com
  tags   = local.tags
}
output "acm_cert" { value = module.acm.cert_arn }

# dns alias a-record for alb
module "dns_alias_alb" {
  source         = "./modules/dns_alias"
  zone           = var.zone # foo.com
  fqdn           = var.fqdn # service.foo.com
  target         = module.alb.alb_dns_name
  target_zone_id = module.alb.alb_zone_id
}

## alb tg
resource "aws_lb_target_group" "alb_tg" {
  name        = "alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"
  tags        = local.tags
  health_check {
    enabled = true
    path    = "/"
    timeout = 10
  }
}
## attach main ec2 instance to target group
resource "aws_lb_target_group_attachment" "alg_tg_att" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = module.ec2.ec2_instance_id
  port             = 80
}

## alb tg hotstandby
resource "aws_lb_target_group" "alb_tg_hotstandby" {
  name        = "alb-tg-hotstandby"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"
  tags        = local.tags
  health_check {
    enabled = true
    path    = "/"
    timeout = 10
  }
}
## attach hotstandby ec2 instance to target group
resource "aws_lb_target_group_attachment" "alg_tg_att_hotstandby" {
  target_group_arn = aws_lb_target_group.alb_tg_hotstandby.arn
  target_id        = module.ec2-2.ec2_instance_id
  port             = 80
}

module "alb" {
  source         = "./modules/alb_ssl"
  alb_name       = "alb-hsby"
  alb_subnet_ids = module.vpc.public_subnet_ids
  alb_securitygroup_ids = [
    aws_security_group.allow-ping.id,
    aws_security_group.allow-https.id
  ]
  alb_cert_arn        = module.acm.cert_arn
  alb_targetgroup_arn = aws_lb_target_group.alb_tg.arn
  tags                = local.tags
}
