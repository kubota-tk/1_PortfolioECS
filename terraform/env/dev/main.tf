##各モジュールの呼び出し

######## vpcモジュール ########
module "vpc" {
  source        = "../../modules/vpc"
  project_name  = var.project_name
  vpccidr       = var.vpccidr
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
  private_subnet_3_cidr = var.private_subnet_3_cidr
  private_subnet_4_cidr = var.private_subnet_4_cidr
}

######## security_group モジュール########
module "security_group" {
  source = "../../modules/security_group"
  vpc_id        = module.vpc.vpc_id
  project_name  = var.project_name
  pri_sub_1_id  = module.vpc.pri_sub_1_id
  pri_route_table_1_id = module.vpc.pri_route_table_1_id
  pri_route_table_2_id = module.vpc.pri_route_table_2_id
}

######## ec2モジュール########
module "ec2" {
  source = "../../modules/ec2"
  project_name  = var.project_name
  aws_region    = var.aws_region
  instance_type = var.instance_type
  volume_size   = var.volume_size
  volume_type   = var.volume_type
  key_name      = var.key_name
  ami           = var.ami
  ec2-sg-id           = module.security_group.ec2-sg-id
  alb-sg-id           = module.security_group.alb-sg-id
  pub_sub_1_id        = module.vpc.pub_sub_1_id
  pub_sub_2_id        = module.vpc.pub_sub_2_id
  s3_app_storage_id   = module.s3.s3_app_storage_id
}

######## s3モジュール ########
module "s3" {
  source = "../../modules/s3"
  project_name = var.project_name
  bucket_name_app_storage = var.bucket_name_app_storage
  bucket_name_log = var.bucket_name_log
}

######## albモジュール ########
module "alb" {
  source = "../../modules/alb"
  project_name    = var.project_name
  vpc_id          = module.vpc.vpc_id
  pub_sub_1_id    = module.vpc.pub_sub_1_id
  pub_sub_2_id    = module.vpc.pub_sub_2_id
  alb-sg-id       = module.security_group.alb-sg-id
}

######## rdsモジュール ########
module "rds" {
  source = "../../modules/rds"
  portfolio_db_username = var.portfolio_db_username
  portfolio_db_password = var.portfolio_db_password 
  project_name = var.project_name
  rds_identifier = var.rds_identifier
  db_engine_name           = var.db_engine_name
  my_sql_major_version     = var.my_sql_major_version
  my_sql_minor_version     = var.my_sql_minor_version
  db_instance_class        = var.db_instance_class
  db_instance_storage_size = var.db_instance_storage_size
  db_instance_storage_type = var.db_instance_storage_type
  db_name                  = var.db_name
  pri_sub_3_id = module.vpc.pri_sub_3_id
  pri_sub_4_id = module.vpc.pri_sub_4_id
  rds-sg-id    = module.security_group.rds-sg-id
}

######## ecrモジュール #######
module "ecr" {
  source = "../../modules/ecr"
  project_name    = var.project_name
//  aws_region      = var.aws_region  
//  aws_account_id  = var.aws_account_id
//  ecs_image_1_url   = var.ecs_image_1_url
  repository_name_1 = var.repository_name_1
  repository_name_2 = var.repository_name_2
}

######## ecsモジュール ########
module "ecs" {
  source = "../../modules/ecs"
  project_name       = var.project_name
  aws_region         = var.aws_region
  ecs_cluster_name   = var.ecs_cluster_name
  ecs_service_name   = var.ecs_service_name
  ecs_task_name      = var.ecs_task_name
  ecs_task_cpu_unit  = var.ecs_task_cpu_unit
  ecs_task_memory    = var.ecs_task_memory
  ecs_desired_count  = var.ecs_desired_count
  ecs_health_check_grace_period_seconds = var.ecs_health_check_grace_period_seconds

##コンテナ1
  ecs_container_1_name  = var.ecs_container_1_name
  ecs_image_1_url       = var.ecs_image_1_url
  ecs_image_1_version   = var.ecs_image_1_version
  ecs_container_1_cpu_unit = var.ecs_container_1_cpu_unit
  ecs_container_1_memory   = var.ecs_container_1_memory
  ecs_container_1_mem_reservation = var.ecs_container_1_mem_reservation
  portfolio_db_username = var.portfolio_db_username
  portfolio_db_password = var.portfolio_db_password
  rds_endpoint          = var.rds_endpoint
##コンテナ2
  ecs_container_2_name  = var.ecs_container_2_name
  ecs_image_2_url       = var.ecs_image_2_url
  ecs_image_2_version   = var.ecs_image_2_version
  ecs_container_2_port  = var.ecs_container_2_port
  ecs_container_2_cpu_unit = var.ecs_container_2_cpu_unit
  ecs_container_2_memory   = var.ecs_container_2_memory
  ecs_container_2_mem_reservation = var.ecs_container_2_mem_reservation
  ecs_container_2_app_protocol    = var.ecs_container_2_app_protocol

  pri_sub_1_id    = module.vpc.pri_sub_1_id 
  pri_sub_2_id    = module.vpc.pri_sub_2_id
  ecs-sg-id       = module.security_group.ecs-sg-id
  alb_id          = module.alb.alb_id
  alb_target_arn  = module.alb.alb_target_arn  
  s3_app_storage_id   = module.s3.s3_app_storage_id
}

######## snsモジュール ########
module "sns" {
  source = "../../modules/sns"
  project_name           = var.project_name
  email                  = var.email
  environment_identifier = var.environment_identifier
}

######## cloudwatchモジュール ########
module "cloudwatch" {
  source = "../../modules/cloudwatch"
  project_name           = var.project_name
  aws_region             = var.aws_region
  environment_identifier = var.environment_identifier
  alb_target_arn_suffix  = module.alb.alb_target_arn_suffix
  alb_arn_suffix         = module.alb.alb_arn_suffix
  sns_topic_name   = module.sns.sns_topic_name
}

