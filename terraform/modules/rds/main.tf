data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_db_instance" "db_instance" {
  identifier        = var.rds_identifier
  engine            = var.db_engine_name
  engine_version    = "${var.my_sql_major_version}.${var.my_sql_minor_version}"
  instance_class    = var.db_instance_class
  availability_zone = element(data.aws_availability_zones.available.names, 0)
  allocated_storage = var.db_instance_storage_size
  storage_type      = var.db_instance_storage_type
  db_name           = var.db_name

  username = var.portfolio_db_username
  password = var.portfolio_db_password

  db_subnet_group_name       = aws_db_subnet_group.db_subnet_group.id
  publicly_accessible        = false
  multi_az                   = false
  auto_minor_version_upgrade = false
  parameter_group_name       = aws_db_parameter_group.db_parameter_group.id
  vpc_security_group_ids     = [var.rds-sg-id]
  
//  apply_immediately = true   #即時反映、apply後にreboot
//  deletion_protection = true  #trueで削除保護
  backup_retention_period    = 7
  skip_final_snapshot    = true
  tags = {
    Name = "${var.project_name}-rds"
  }
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name        = "portfolioecs-db-parameter-gp"
  description = "MySQL Parameter Group"
  family      = "mysql${var.my_sql_major_version}"
  tags = {
    Name = "${var.project_name}-db-parametergp"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "portfolioecs-db-subnetgp"
  description = "DBSubnetGroup"
  subnet_ids = [
    var.pri_sub_3_id,
    var.pri_sub_4_id
  ]
  tags = {
    Name = "${var.project_name}-db-subnetgp"
  }
}



