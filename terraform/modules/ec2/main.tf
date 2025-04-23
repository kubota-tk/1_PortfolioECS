#############################
########     ec2    #########
#############################

######## ネットワーク インタフェース ########
resource "aws_network_interface" "ec2_network_interface" {
  subnet_id = var.pub_sub_1_id
}

######## ec2 インタフェース ########
resource "aws_instance" "ec2_instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.pub_sub_1_id
  iam_instance_profile        = aws_iam_instance_profile.ec2_iam_instance_profile.id
  vpc_security_group_ids      = [var.ec2-sg-id]
  associate_public_ip_address = true
  key_name = var.key_name
  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = "true"
    encrypted             = "true"
  }
  tags = {
    Name = "${var.project_name}-ec2"
  }
  user_data = <<-EOF
  #!/bin/bash
  sudo yum install git -y
  EOF
}

######## elastic ipアドレス########
resource "aws_eip" "ip_assos" {
  domain   = "vpc"
  instance = aws_instance.ec2_instance.id
}

#############################
########  iam Role  #########
#############################
##SSM,Exec,ECR Push,s3(app-storage,aws s3 ls用)のポリシー

######## Policy（SSM,Exec,ECR,S3）########
resource "aws_iam_policy" "ec2_iam_policy" {
  name   = "${var.project_name}-ssm-exec-ecr-s3-allow-policy_for_ec2"
  policy = <<EOF
{
  "Version"     : "2012-10-17",
  "Statement"   : [
    {
      "Sid"     : "AllowSssmExec",
      "Effect"  : "Allow",
      "Action"  : [
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:CreateControlChannel"
      ],
      "Resource": "*"
    },
    {
      "Sid"     : "AllowEcsExec",
      "Effect"  : "Allow",
      "Action"  : [
              "ecs:DescribeServices",
              "ecs:DescribeTasks",
              "ecs:ExecuteCommand"
      ],
      "Resource": "*"
    },
    {
      "Sid"     : "AllowEcrPush",
      "Effect"  : "Allow",
      "Action"  : [
              "ecr:GetAuthorizationToken",
              "ecr:InitiateLayerUpload",
              "ecr:UploadLayerPart",
              "ecr:CompleteLayerUpload",
              "ecr:PutImage",
              "ecr:BatchCheckLayerAvailability"
      ],
      "Resource": "*"
    },
    {
      "Sid"     : "AllowAppPicStorage",
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
    },
    {
      "Sid"     : "AllowS3List",
      "Effect": "Allow",
      "Action": "s3:ListAllMyBuckets",
      "Resource": "arn:aws:s3:::*"
    }
  ] 
}
EOF
}

######## Role（SSM,Exec,ECR,S3）########
resource "aws_iam_role" "ec2_iam_role" {
  name = "${var.project_name}-ssm-exec-ecr-s3-allow-role_for_ec2"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ecs-tasks.amazonaws.com",
          "ec2.amazonaws.com"
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

######## Attachment（SSM,Exec,ECR,S3）########
resource "aws_iam_role_policy_attachment" "ssm_ecr_allow_role_for_ec2_attach" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = aws_iam_policy.ec2_iam_policy.arn
}

######## INstance Profile（SSM,Exec,ECR,S3） #######
resource "aws_iam_instance_profile" "ec2_iam_instance_profile" {
  path = "/"
  name = aws_iam_role.ec2_iam_role.name
  role = aws_iam_role.ec2_iam_role.name
}


