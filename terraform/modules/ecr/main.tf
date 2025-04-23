###### ECR appイメージ ######
resource "aws_ecr_repository" "ecr_repo_1" {
  name = "${var.repository_name_1}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {    ##コンテナイメージのセキュリティ診断
    scan_on_push = true
  }
  tags = {
    Name = "${var.project_name}-repo1"
  }
}

###### ECR nginxイメージ ######
resource "aws_ecr_repository" "ecr_repo_2" {
  name = "${var.repository_name_2}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {    ##コンテナイメージのセキュリティ診断
    scan_on_push = true
  }
  tags = {
    Name = "${var.project_name}-repo2"
  }
}




##imageのpushまでの自動実行
##時間がかかるので注意
##・nginxのDokcerfileも読み込むこと
##・Dockerfileのファイルパスを変更すること
##・Dockerfileの場所
##（appはraise~内、nginxはraise~/nginx内）

//resource "null_resource" "default" {
//
//  triggers = {
//    registry_arn = aws_ecr_repository.ecr_repo.arn
//  }
//
//  provisioner "local-exec" {
//    command = "$(aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com)"
//  }
//  provisioner "local-exec" {
//    command = "docker build -t ${var.repository_name} --platform linux/amd64 ."
//  }
//  provisioner "local-exec" {
//    command = "docker tag ${aws_ecr_repository.ecr_repo.name}:latest ${var.ecs_image_1_url}:latest"
//  }
//  provisioner "local-exec" {
//    command = "docker push ${var.ecs_image_1_url}:latest"
//  }
//}


