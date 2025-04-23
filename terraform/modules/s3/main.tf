####### 1バケット目 ########

####### s3バケット（アプリ画像保管用） #########
resource "aws_s3_bucket" "app_storage_bucket" {
  bucket = "${var.bucket_name_app_storage}"
  tags = {
    Name = "${var.project_name}-s3-bucket-app-storage"
  }
}

######## publick access（アプリ画像保管用） ########
resource "aws_s3_bucket_public_access_block" "pub_block_app_storage_bucket" {
  bucket                  = aws_s3_bucket.app_storage_bucket.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

######## 暗号化（アプリ画像保管用） ########
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_app_storage_backet" {
  bucket = aws_s3_bucket.app_storage_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


######## 2バケット目 ########

######## s3バケット（ログ保管用） #########
resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.bucket_name_log}"
  tags = {
    Name = "${var.project_name}-s3-bucket-log"
  }
}

######## publick access（ログ保管用） ########
resource "aws_s3_bucket_public_access_block" "pub_block_log_bucket" {
  bucket                  = aws_s3_bucket.log_bucket.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

######## 暗号化（ログ保管用） ########
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_log_backet" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


##<<参考>> バージョニング設定
##resource "aws_s3_bucket_versioning" "s3_versioning" {
##  bucket = aws_s3_bucket.s3_bucket.id
##  versioning_configuration {
##    status = "Disabled"
##  }
##}



