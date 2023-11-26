terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.58.0"
    }

  }
#   backend "s3" {
#     bucket         = "haris-terraform-state"
#     region         = "us-east-2"
#     key            = "terraform.tfstate"
#     dynamodb_table = "terraform-tfstate"
#     role_arn = "arn:aws:iam::349739699720:role/service-role/terraform-infra"
#   }

}


module "OMAPP" {
  region                     = var.region
  source                     = "./modules/order_management_app"
  environment = var.environment
  db_password = var.db_password
  db_username = var.db_username
  access_key = var.access_key
  secret_key = var.secret_key

}

output "api_url" {
  value=module.OMAPP.api_url
}

output "db_endpoint" {
  value=module.OMAPP.db_instance_address
}
