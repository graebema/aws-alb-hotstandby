variable "name" {
  description = "name of the vpc"
}

variable "vpc_cidr_block" {
  description = "The range of IP address to associate to the VPC in CIDR notation"
  default     = "10.0.0.0/16"
}

variable "subnet_count" {
  description = "Number of subnets pair (public/private) to create, normally one for each AZ."
  default     = 3
}
variable "newbits" {
  description = "number of additional bits with which to extend the prefix for subnet calculation"
  default     = 8
}
variable "netnum_public" {
  description = "netnum to calculate public cidrsubnet, must be less than newbits"
  default     = 1
}
variable "netnum_private" {
  description = "netnum to calculate private cidrsubnet, must be less than newbits"
  default     = 4
}
variable "public_subnet_cidr_list" {
  type        = list(string)
  description = "list of cidr ranges for public subnets"
  default     = null
}
variable "private_subnet_cidr_list" {
  type        = list(string)
  description = "list of cidr ranges for private subnets"
  default     = null
}
