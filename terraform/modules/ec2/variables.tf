##子モジュール側での変数定義

##親モジュールのあるenvで設定
variable "project_name" {}
variable "aws_region" {}
variable "instance_type" {}
variable "volume_size" {}
variable "volume_type" {}
variable "key_name" {}
variable "ami" {}

## 他モジュールのoutputで設定
variable "pub_sub_1_id" {}
variable "pub_sub_2_id" {}
variable "ec2-sg-id" {}
variable "alb-sg-id" {}
variable "s3_app_storage_id" {}


