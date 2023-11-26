# RDS Outputs

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.rds_instance.endpoint
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.rds_instance.address
}

output "db_instance_password" {
  description = "The master password"
  value       = aws_db_instance.rds_instance.password
  sensitive   = true
}


# API GATEWAY
output "api_gateway_rest_api_id" {
  description = "rest_api_id"
  value= aws_api_gateway_rest_api.order_api.id
}

output "api_url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}
