##dev,prodと開発環境ごとに分けた場合を想定
##環境ごとに異なる変数を記載
##以下は環境変数を参照
##  region(var.aws_region)
##  password(var.portfolio_db_password)
##  username(var.portfolio_db_username)
##  account_id(var.aws_account_id)


######## サービス全体 ########
project_name = "PortfolioECS"
environment_identifier = "email" ##snsトピックの識別子

######## vpcモジュール ########
vpccidr = "10.10.0.0/16"
public_subnet_1_cidr  = "10.10.10.0/24"
public_subnet_2_cidr  = "10.10.30.0/24"
private_subnet_1_cidr = "10.10.100.0/24"
private_subnet_2_cidr = "10.10.130.0/24"
private_subnet_3_cidr = "10.10.200.0/24"
private_subnet_4_cidr = "10.10.230.0/24"

######## security_group モジュール########

######## ec2モジュール########
instance_type = "t2.micro"
volume_size   = "8"
volume_type   = "gp2"
key_name      = "PortfolioECS-keypair"
ami           = "ami-031ff5a575101728a"
##ami         = "amzn2-ami-kernel-5.10-hvm-2.0.20240816.0-x86_64-gp2"

######## s3モジュール ########
bucket_name_app_storage = "portfolio-ecs-picture"
bucket_name_log = "logs-s3-various"

######## albモジュール ########

######## rdsモジュール ########
rds_identifier = "portfolio-ecs-db"
db_engine_name           = "mysql"
my_sql_major_version     = "8.0"
my_sql_minor_version     = "36"
db_instance_class        = "db.t3.micro"
db_instance_storage_size = "20"
db_instance_storage_type = "gp2"
db_name                  = "PortfolioEcsDB"

######## ecrモジュール ########
repository_name_1 = "portfolio_ecs_app"
repository_name_2 = "portfolio_ecs_nginx"

######## ecsモジュール ########
ecs_cluster_name       = "cluster"
ecs_service_name       = "service"
ecs_task_name          = "task"
ecs_task_cpu_unit      = 512  ##[256,512,1024,2048,4096]
ecs_task_memory        = 1024  ##[256,512,1024,2048,4096]
ecs_desired_count      = 1
ecs_health_check_grace_period_seconds = 60 ##ヘルスチェック猶予期間

##appコンテナ
ecs_container_1_name     = "app_container"
ecs_image_1_url = "891377211926.dkr.ecr.ap-northeast-1.amazonaws.com/portfolio_ecs_app"
ecs_image_1_version      = "latest"
ecs_container_1_cpu_unit = 256
ecs_container_1_memory   = 512
ecs_container_1_mem_reservation = 512
rds_endpoint = "portfolio-ecs-db.cd0ca0y00ua6.ap-northeast-1.rds.amazonaws.com"

##nginxコンテナ
ecs_container_2_name     = "nginx_container"
ecs_image_2_url = "891377211926.dkr.ecr.ap-northeast-1.amazonaws.com/portfolio_ecs_nginx"
ecs_image_2_version      = "latest"
ecs_container_2_port     = 80
ecs_container_2_cpu_unit = 128
ecs_container_2_memory   = 128
ecs_container_2_mem_reservation = 128
ecs_container_2_app_protocol = "http"

######## snsモジュール ########
email = "nffaog@onetm-ml.com"

######## cloudwatchモジュール ########



