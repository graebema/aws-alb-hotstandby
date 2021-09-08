variable "fqdn" {
  type        = string
  description = "fqdn eg. service.example.com"
  default     = "service.example.com"
}
variable "zone" {
  type        = string
  description = "zone name eg. example.com"
  default     = "example.com"
}
variable "iam_account_id" {
  type        = string
  description = "account id the code is allowed to be executed with"
}
