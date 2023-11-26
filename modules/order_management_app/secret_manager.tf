resource "aws_secretsmanager_secret" "db_secrets" {
  name                    = "db_secrets"
  description             = "Database credentials"
  recovery_window_in_days = 0
  tags = {
    Name        = "db_secrets"
    Environemnt = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "secret_val" {
  secret_id = aws_secretsmanager_secret.db_secrets.id
  # TODO: Figure out a way to generate mapping structure that presents this
  #       key/value pair structure in a more readable way. Maybe use template files?
  secret_string = jsonencode({ "password" : "${var.db_password}", "username" : "${var.db_username}", "db_host" : "${aws_db_instance.rds_instance.address}" })
}