##
## SG FOR RDS
##
resource "aws_security_group" "rds_sg" {
  name = "rds_sg"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


##
## RDS RESOURCE INSTANCE
##
resource "aws_db_instance" "rds_instance" {
  engine               = "mysql"
  identifier           = "beam-rds"
  db_name              = "Beam"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql5.7"
  multi_az             = false

  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  skip_final_snapshot    = true
  publicly_accessible    = true
}