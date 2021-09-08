# variables.tf
variable "name" {
  type        = string
  description = "name of the ec2 instance"
}

variable "ubuntu_version" {
  type        = string
  description = "ubuntu os version"
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

variable "subnet_id" {
  description = "subnet idwhere the instance is deployed to"
  type        = string
}

variable "securitygroups" {
  type        = list(string)
  description = "array of security groups for the instance"
  default     = []
}

variable "path_to_ssh_public_key" {
  type        = string
  description = "optional: ssh public key file"
  default     = null
}

variable "aws_region" {
  type        = string
  description = "The AWS region things are created in"
}
variable "instance_type" {
  type        = string
  description = "architecture of the instance"
  default     = "t2.micro"
}
variable "ebs_size" {
  description = "The size of the EBS volume in GB"
}
variable "ebs_kms_key_arn" {
  type        = string
  description = "kms key arn for ebs encryption"
}
variable "ebs_mountpoint" {
  type        = string
  description = "mountpoint for the ebs volume"
  default     = "/data"
}

variable "ebs_device_name" {
  type        = string
  description = "linux ebs device name for lvm"
  # for nitro systems eg. T3.medium use /dev/nvme1n1 otherwise same as instance_device_name
  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#ec2-nitro-instances
  default = "/dev/xvdh"
}

variable "instance_device_name" {
  type        = string
  description = "linux ebs device name, usually /dev/xvd* "
  default     = "/dev/xvdh"
}

variable "availability_zone" {
  type        = string
  description = "The AZ the EBS volume will be created"
}

variable "additional_policy_arn" {
  description = "optional: aws_iam_policy arn to attach to current instance profile"
  type        = string
  default     = null
}

variable "init_script" {
  description = "optional: filepath to shell script for execution when creating instance"
  type        = string
  default     = null
}

variable "tags" {
  description = "hash map of key/value pairs for tagging"
  type        = map(string)
}

variable "cloudwatch_config_file" {
  type        = string
  description = "json file with cloudwatch config"
}

variable "architecture" {
  type        = string
  description = "x86_64|arm64"
  default     = "x86_64"
}

variable "ami" {
  type        = string
  description = "ami id"
  default     = null
}

variable "root_volume_size" {
  description = "The size of the root volume in GB"
  default     = 8
}

variable "private_ip" {
  description = "fixed private ip"
  default     = null
}

variable "metadata_enabled" {
  description = "enable or disable instance metadata http endpoint, valid values are enabled or disabled"
  default     = "enabled"
}

variable "delete_on_termination" {
  description = "delete root volume on termination"
  default     = true
}

variable "init_script_vars" {
  type        = map(string)
  description = "optional: variables for the init script"
  default     = null
}

variable "cw_sns_topic_arn" {
  type        = string
  description = "sns topic arn to send the cloudwatch alarm notifications to"
  default     = null
}
