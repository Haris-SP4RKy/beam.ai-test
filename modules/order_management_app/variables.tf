variable "region" {
  type = string
}
# variable "vpc_cidr" {
#   type = string
# }
variable "environment" {
  type = string
}
variable "db_username" {
  type      = string
  sensitive = true
}
variable "db_password" {
  type      = string
  sensitive = true
}
variable "access_key" {
  type = string
}
variable "secret_key" {
  type = string
}