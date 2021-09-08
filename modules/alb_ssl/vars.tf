variable "alb_subnet_ids" {
  type        = list(string)
  description = "subnet array, minimum 2 members (2 AZ configuration)"
}
variable "alb_securitygroup_ids" {
  type        = list(string)
  description = "security group array assigned to the alb"
}
variable "alb_name" {
  type        = string
  description = "name of the application loadbalancer"
}
variable "alb_cert_arn" {
  type        = string
  description = "arn of the acm certificate for the loadbalancer"
}
variable "alb_targetgroup_arn" {
  type        = string
  description = "arn of the alb target group"
}


# for content of map see:
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
variable "aws_alb_accounts" {
  type = map(string)
  default = {
    eu-central-1   = "054676820928"
    eu-west-1      = "156460612806"
    eu-west-2      = "652711504416"
    eu-west-3      = "009996457667"
    eu-north-1     = "897822967062"
    us-east-1      = "127311923021"
    us-east-2      = "033677994240"
    us-west-1      = "027434742980"
    us-west-2      = "797873946194"
    ap-southeast-1 = "114774131450"
    ap-southeast-2 = "783225319266"
    sa-east-1      = "507241528517"
  }
}
variable "tags" {
  description = "hash map of key/value pairs for tagging"
  type        = map(string)
}
variable "internal" {
  description = "true/false  internal lb"
  default     = false
}
