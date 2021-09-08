provider "aws" {
  region = local.region
  allowed_account_ids = [
    var.iam_account_id
  ]
}

provider "http" {
}

module "vpc" {
  source         = "./modules/vpc"
  subnet_count   = local.availability_zone_count
  vpc_cidr_block = local.vpc_cidr_block
  name           = "hsby-vpc"
}
