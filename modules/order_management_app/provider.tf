provider "aws" {
  region = var.region
  # assume_role {
  #   role_arn = "arn:aws:iam::349739699720:role/service-role/terraform-infra"
  # }
  access_key = var.access_key
  secret_key = var.secret_key
}