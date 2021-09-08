variable "fqdn" {
  type        = string
  description = "fqdn eg. service.example.com"
}
variable "zone" {
  type        = string
  description = "zone name eg. example.com"
}
variable "target" {
  type        = string
  description = "target name"
}
variable "target_zone_id" {
  type        = string
  description = "target zone_id, eg. from a loadbalancer"
}

variable "tags" {
  description = "hash map of key/value pairs for tagging"
  type        = map(string)
  default     = {}
}
