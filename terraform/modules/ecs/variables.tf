##子モジュール側での変数定義

##親モジュールのあるenvで設定
variable "project_name" {}
variable "aws_region" {}
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
variable "portfolio_db_username" {}
variable "portfolio_db_password" {}
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

## 他モジュールのoutputで設定

variable "pri_sub_1_id" {}
variable "pri_sub_2_id" {}
variable "ecs-sg-id" {}
variable "alb_id" {}
variable "alb_target_arn" {}
variable "s3_app_storage_id" {}

