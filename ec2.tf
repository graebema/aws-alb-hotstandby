resource "aws_kms_key" "key" {
  description             = "Key used for encrypting storage"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 30
  is_enabled              = true
  enable_key_rotation     = true
  tags                    = local.tags
}

resource "aws_kms_alias" "key_alias" {
  name          = "alias/ebs_ec2"
  target_key_id = aws_kms_key.key.id
}

module "ec2" {
  source    = "./modules/ec2-ux"
  name      = "ec2-main"
  subnet_id = module.vpc.private_subnet_ids.0
  securitygroups = [
    aws_security_group.allow-ping.id,
    aws_security_group.allow-http-alb.id
  ]
  aws_region             = local.region
  instance_device_name   = "/dev/xvdh"
  instance_type          = "t2.micro"
  ebs_size               = 1
  ebs_kms_key_arn        = aws_kms_key.key.arn
  ebs_mountpoint         = "/data"
  availability_zone      = "eu-central-1a"
  cloudwatch_config_file = "cloudwatch_cfg.json"
  init_script            = "httpd.sh"
  tags                   = local.tags
}

module "ec2-2" {
  source    = "./modules/ec2-ux"
  name      = "ec2-hotstandby"
  subnet_id = module.vpc.private_subnet_ids.1
  securitygroups = [
    aws_security_group.allow-ping.id,
    aws_security_group.allow-http-alb.id
  ]
  aws_region             = local.region
  instance_device_name   = "/dev/xvdh"
  instance_type          = "t2.micro"
  ebs_size               = 1
  ebs_kms_key_arn        = aws_kms_key.key.arn
  ebs_mountpoint         = "/data"
  availability_zone      = "eu-central-1b"
  cloudwatch_config_file = "cloudwatch_cfg.json"
  init_script            = "httpd.sh"
  tags                   = local.tags
}

resource "aws_cloudwatch_log_group" "cw_loggroup" {
  name = "/aws/ec2-ubuntu/syslog"
}
