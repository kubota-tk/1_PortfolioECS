##ルートモジュールでの変数定義
##terraform.tfvarsで値を設定

######## サービス全体 ########
variable "project_name" {}
variable "aws_region" {}
variable "environment_identifier" {}
variable "portfolio_db_username" {}
variable "portfolio_db_password" {}

######## vpcモジュール ########
variable "vpccidr" {}
variable "public_subnet_1_cidr" {}
variable "public_subnet_2_cidr" {}
variable "private_subnet_1_cidr" {}
variable "private_subnet_2_cidr" {}
variable "private_subnet_3_cidr" {}
variable "private_subnet_4_cidr" {}

######## security_group モジュール########

######## ec2モジュール########
variable "instance_type" {}
variable "volume_size" {}
variable "volume_type" {}
variable "key_name" {}
variable "ami" {}

######## s3モジュール ########
variable "bucket_name_app_storage" {}
variable "bucket_name_log" {}

######## albモジュール ########

######## rdsモジュール ########
variable "rds_identifier" {}
variable "db_engine_name" {}
variable "my_sql_major_version" {}
variable "my_sql_minor_version" {}
variable "db_instance_class" {}
variable "db_instance_storage_size" {}
variable "db_instance_storage_type" {}
variable "db_name" {}

######## ecrモジュール ########
variable "aws_account_id" {}
variable "repository_name_1" {}
variable "repository_name_2" {}

######## ecsモジュール ########
variable "ecs_cluster_name" {}
variable "ecs_service_name" {}
variable "ecs_task_name" {}
variable "ecs_task_cpu_unit" {}
variable "ecs_task_memory" {}
variable "ecs_desired_count" {}
variable "ecs_health_check_grace_period_seconds" {}

##コンテナ1
variable "ecs_container_1_name" {}
variable "ecs_image_1_url" {}
variable "ecs_image_1_version" {}
variable "ecs_container_1_cpu_unit" {}
variable "ecs_container_1_memory" {}
variable "ecs_container_1_mem_reservation" {}
variable "rds_endpoint" {}
##コンテナ2
variable "ecs_container_2_name" {}
variable "ecs_image_2_url" {}
variable "ecs_image_2_version" {}
variable "ecs_container_2_port" {}
variable "ecs_container_2_cpu_unit" {}
variable "ecs_container_2_memory" {}
variable "ecs_container_2_mem_reservation" {}
variable "ecs_container_2_app_protocol" {}


######## snsモジュール ########
variable "email" {}

######## cloudwatchモジュール ########


