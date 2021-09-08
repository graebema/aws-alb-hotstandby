variable "fqdn" {
  type        = string
  description = "fqdn of the cert eg. service.example.com"
}
variable "zone" {
  type        = string
  description = "zone name eg. example.com"
}
variable "tags" {
  description = "hash map of key/value pairs for tagging"
  type        = map(string)
}
variable "san" {
  description = "array of SAN names"
  type        = list(string)
  default     = []
}
