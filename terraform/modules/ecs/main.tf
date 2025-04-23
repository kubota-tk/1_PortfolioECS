##################################
########       ECS        ########
##################################

###### ECS Cluster ########
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name = "${var.project_name}_cluster"
  }
}

######## ECS Service ########
resource "aws_ecs_service" "ecs_service" {
  name                              = var.ecs_service_name
  cluster                           = aws_ecs_cluster.ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.ecs_task_def_app.arn
  desired_count                     = var.ecs_desired_count
  health_check_grace_period_seconds = var.ecs_health_check_grace_period_seconds
  launch_type                       = "FARGATE"
  force_new_deployment              = true    ##新しいデプロイの強制
  enable_execute_command = true
  network_configuration {
    assign_public_ip = false
    security_groups = [var.ecs-sg-id]
    subnets         = [
      var.pri_sub_1_id,
      var.pri_sub_2_id
    ]
  }
  load_balancer {
    target_group_arn = var.alb_target_arn
    container_name   = var.ecs_container_2_name
    container_port   = var.ecs_container_2_port
  }
  tags = {
    Name = "${var.project_name}-service"
  }
  depends_on = [var.alb_id] ##albとの依存関係
}

######## Log Groupe （コンテナ別）########
resource "aws_cloudwatch_log_group" "container_1" {
  name              = "/ecs/${var.ecs_task_name}/${var.ecs_container_1_name}"
  retention_in_days = 7
}
resource "aws_cloudwatch_log_group" "container_2" {
  name              = "/ecs/${var.ecs_task_name}/${var.ecs_container_2_name}"
  retention_in_days = 7
}


######## Execution Role(タスク起動用) #######
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Action": [ 
        "sts:AssumeRole"
      ]
    }
  ]  
}
EOF
}

##CloudWatchにログ送信可能なポリシー
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

######## Task Role（コンテナ用）########
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"
  assume_role_policy = <<EOF
{   
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { 
        "Service": [
          "ecs-tasks.amazonaws.com" 
        ]
      },
      "Action": [    
        "sts:AssumeRole"
      ]
    }
  ]
}
EOF
}

######## Task Poricy SSM&S3（コンテナ用）
resource "aws_iam_policy" "ecs_task_role_policy" {
  name = "ecs-task-policy-ssm-s3-parameters"
  path = "/service-role/"
  policy = <<EOF
{   
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParametersByPath",
        "ssm:GetParameters",
        "ssm:GetParameter"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:CreateControlChannel"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
      ],
      "Resource": [
          "arn:aws:s3:::${var.s3_app_storage_id}",
          "arn:aws:s3:::${var.s3_app_storage_id}/*"
      ]
    }
  ]
}
EOF
}

## Task Role（コンテナ用）へのポリシー割り当て
resource "aws_iam_role_policy_attachment" "ecs_task_role_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_role_policy.arn
}

######## タスク定義 ########
resource "aws_ecs_task_definition" "ecs_task_def_app" {
  family                    = "${var.project_name}_${var.ecs_task_name}"
  cpu                       = var.ecs_task_cpu_unit
  memory                    = var.ecs_task_memory
  network_mode              = "awsvpc"
  requires_compatibilities  = [ "FARGATE" ]
  execution_role_arn        = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn             = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
##コンテナ１(app)
    {
      name      = var.ecs_container_1_name
      image     = "${var.ecs_image_1_url}:${var.ecs_image_1_version}"
      cpu       = var.ecs_container_1_cpu_unit
      memory    = var.ecs_container_1_memory
      memoryReservation = var.ecs_container_1_mem_reservation  ##空きメモリは他コンテナが使用
      environment = [
        {
          "name"  = "DB_ROOT_USERNAME"
          "value" = var.portfolio_db_username
        },
        {
          "name"  = "DB_ROOT_PASSWORD"
          "value" = var.portfolio_db_password
        },
        {
          "name"  = "TZ"
          "value" = "Asia/Tokyo"
        },
        {
          "name"  = "DB_HOST"
          "value" = "var.rds_endpoint"
        }
      ]
      essential = true  ##コンテナ異常時の一斉停止
      logConfiguration = {       ##logの収集
        logDriver = "awslogs"
        options   = {
          awslogs-region : "ap-northeast-1"
          awslogs-group : aws_cloudwatch_log_group.container_1.name
          awslogs-stream-prefix : "ecs"
        }
      }
     },
##コンテナ2(nginx)
     {
      name      = var.ecs_container_2_name
      image     = "${var.ecs_image_2_url}:${var.ecs_image_2_version}"
      cpu       = var.ecs_container_2_cpu_unit
      memory    = var.ecs_container_2_memory
      memoryReservation = var.ecs_container_2_mem_reservation  ##空きメモリは他コンテナが使用
      essential = true  ##コンテナ異常時の一斉停止
      portMappings = [        ##targetの参照対象
        {
          containerPort = var.ecs_container_2_port
          appProtocol   = var.ecs_container_2_app_protocol
        }
      ]
      volumesFrom = [{     ##socket通信に必要なファイル参照
        sourceContainer: var.ecs_container_1_name
        readOnly: null
      }]
      dependsOn = [{
          containerName: var.ecs_container_1_name
          condition: "START"
      }]
      logConfiguration = {        ##logの収集
        logDriver = "awslogs"
        options   = {
          awslogs-region : var.aws_region
          awslogs-group  : aws_cloudwatch_log_group.container_2.name
          awslogs-stream-prefix : "ecs"
        }
      }    
    }  
  ])  
}


##################################
######## ECS Auto Scaling ########
##################################


##### オートスケール用のiam ######
resource "aws_iam_role" "ecs_autoscale_role" {
  name = "ecs-autoscale-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "application-autoscaling.amazonaws.com"
        ]
      },
      "Action": [
        "sts:AssumeRole"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ecs_autoscale_role_attach" {
    name = "ecs-autoscale-role-attach"
    roles = ["${aws_iam_role.ecs_autoscale_role.name}"]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}


##### アラーム スケールアウト判定（CPU平均使用率75以上が1回） ######
resource "aws_cloudwatch_metric_alarm" "sacle_out_alerm" {
  alarm_name          = "${var.project_name}-ECSService-CPU-Utilization-High-75"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "75"

  dimensions = {
    ClusterName = "${aws_ecs_cluster.ecs_cluster.name}" 
    ServiceName = "${aws_ecs_service.ecs_service.name}" 
  }

  alarm_actions = ["${aws_appautoscaling_policy.scale_out.arn}"]
}

##### アラーム スケールイン判定（CPU平均使用率25より低いが１回） ######
resource "aws_cloudwatch_metric_alarm" "sacle_in_alerm" {
  alarm_name          = "${var.project_name}-ECSService-CPU-Utilization-Low-25"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "25"

  dimensions = {
    ClusterName = "${aws_ecs_cluster.ecs_cluster.name}"
    ServiceName = "${aws_ecs_service.ecs_service.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.scale_in.arn}"]
}

### オートスケール基本設定 ###
resource "aws_appautoscaling_target" "ecs_service_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = "${aws_iam_role.ecs_autoscale_role.arn}"
  min_capacity       = 1
  max_capacity       = 2
}

### スケール挙動設定（300秒のクールタイム毎に-1スケールアウト） ###
resource "aws_appautoscaling_policy" "scale_out" {
  name                = "scale-out"
  resource_id         = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension  = "${aws_appautoscaling_target.ecs_service_target.scalable_dimension}"
  service_namespace   = "${aws_appautoscaling_target.ecs_service_target.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.ecs_service_target]
}

### スケール挙動設定（300秒のクールタイム毎に-1スケールイン） ###
resource "aws_appautoscaling_policy" "scale_in" {
  name                = "scale-in"
  resource_id         = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension  = "${aws_appautoscaling_target.ecs_service_target.scalable_dimension}"
  service_namespace   = "${aws_appautoscaling_target.ecs_service_target.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"
    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.ecs_service_target]
}
