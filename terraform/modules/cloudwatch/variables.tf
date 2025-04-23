##子モジュール側での変数定義

##親モジュールのあるenvで設定
variable "project_name" {}
variable "aws_region" {}
variable "environment_identifier" {}

##他モジュールのoutputで設定
variable "sns_topic_name" {}
variable "alb_arn_suffix" {}
variable "alb_target_arn_suffix" {}

