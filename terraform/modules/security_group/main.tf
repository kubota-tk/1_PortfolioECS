######## ECSのセキュリティグループ ########
resource "aws_security_group" "ecs_security_group" {
  name        = "${var.project_name}-ecs-sg"
  description = "Allow connections from ALB, RDS"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description      = "HTTP"
      protocol         = "tcp"
      from_port        = 80
      to_port          = 80
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = [aws_security_group.alb_security_group.id]
      self             = false
    }
  ]
  egress = [
    {
      description      = "RDS"
      protocol         = "tcp"
      from_port        = 3306
      to_port          = 3306
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = [aws_security_group.rds_security_group.id]
      self             = false
    },
    {
      description      = "ECR(HTTPS)"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  tags = {
    Name = "${var.project_name}-ecs-sg"
  }
}


###### RDSのセキュリティグループ(ECS、egressとの循環回避) ######
resource "aws_security_group" "rds_security_group" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow connection from EC2"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}
resource "aws_security_group_rule" "rds_security_group_rule" {
 source_security_group_id = aws_security_group.ecs_security_group.id
 security_group_id = aws_security_group.rds_security_group.id
 from_port         = 3306
 to_port           = 3306
 protocol          = "tcp"
 type              = "ingress"
 description       = "ECS access"
}


######## ALBのセキュリティグループ ########
resource "aws_security_group" "alb_security_group" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow connection from Port80"
  vpc_id      = var.vpc_id
  ingress = [
    {
      description      = "HTTP"
      protocol         = "tcp"
      from_port        = 80
      to_port          = 80
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  egress = [
    {
      description      = "for all outgoing traffics"
      from_port        = 0
      to_port          = 0
      protocol         = -1
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

######## EC2のセキュリティグループ ########
resource "aws_security_group" "ec2_security_group" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allow connections from SSH"
  vpc_id      = var.vpc_id
  ingress = [
    {
      description      = "SSH"
      protocol         = "tcp"
      from_port        = 22
      to_port          = 22
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self = false
    }
  ]
  egress = [
    {
      description      = "HTTPS"
      protocol         = "TCP"      
      from_port        = 443
      to_port          = 443
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

###################################
######### エンドポイント ##########
###################################

######## Endpointのルートテーブル########
#リージョン２つにそれぞれルートテーブル作成

resource "aws_vpc_endpoint_route_table_association" "private_s3_1" {
  vpc_endpoint_id = aws_vpc_endpoint.s3_end_1.id
  route_table_id  = var.pri_route_table_1_id
  depends_on = [aws_vpc_endpoint.s3_end_1]
}
resource "aws_vpc_endpoint_route_table_association" "private_s3_2" {
  vpc_endpoint_id = aws_vpc_endpoint.s3_end_2.id
  route_table_id  = var.pri_route_table_2_id
  depends_on = [aws_vpc_endpoint.s3_end_2]
}

######## Endpointのセキュリティーグループ ########
resource "aws_security_group" "endpoint_sg" {
  name = "vpc-endpoint-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]  # VPCのCIDR
  }
  egress {
    from_port   = 0
    to_port     = 0   
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]   
  }
 tags = { 
    Name = "endpoint-sg"  
  }
}

######## Endpoint（S3 Gateway 1,2) ########
#リージョン２つにそれぞれEndpoint作成

######## S3 Gateway 1 #######
resource "aws_vpc_endpoint" "s3_end_1" {  
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  tags = {
  Name = "s3-endpoint-1"
  }
}
resource "aws_vpc_endpoint_route_table_association" "s3_end_1_association" {
  route_table_id  = var.pri_route_table_1_id
  vpc_endpoint_id = aws_vpc_endpoint.s3_end_1.id
}

######## S3 Gateway 2 #######
resource "aws_vpc_endpoint" "s3_end_2" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  tags = {
  Name = "s3-endpoint-2"
  }
}
resource "aws_vpc_endpoint_route_table_association" "s3_end_2_association" {
  route_table_id  = var.pri_route_table_2_id
  vpc_endpoint_id = aws_vpc_endpoint.s3_end_2.id
}

######## Endpoint（ECR）########
resource "aws_vpc_endpoint" "ecr_api_1" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [var.pri_sub_1_id]
  security_group_ids = [aws_security_group.endpoint_sg.id]  
  tags = {
    Name = "ecr-api-endpoint-1"
  }
}
resource "aws_vpc_endpoint" "ecr_dkr_1" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [var.pri_sub_1_id]
  security_group_ids = [aws_security_group.endpoint_sg.id]
  tags = {
    Name = "ecr-dkr-endpoint-1"
  }
}

######## Endpoint（CloudWatch Logs） ########
resource "aws_vpc_endpoint" "log" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.ap-northeast-1.logs" 
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [var.pri_sub_1_id]
  security_group_ids = [aws_security_group.endpoint_sg.id]
  tags = {
    Name = "logs-endpoint-1"
  }
}

######## Endpoint（SSM,ECSExec） ########
resource "aws_vpc_endpoint" "ssm" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.ap-northeast-1.ssm"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [var.pri_sub_1_id]
  security_group_ids = [aws_security_group.endpoint_sg.id]
  tags = {
    Name = "ssm-endpoint-1"
  }
}
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.ap-northeast-1.ssmmessages"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [var.pri_sub_1_id]
  security_group_ids = [aws_security_group.endpoint_sg.id]
  tags = {
    Name = "ssmmessages-endpoint-1"
 }
}
