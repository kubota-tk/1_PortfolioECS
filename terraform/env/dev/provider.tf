######## provider ########
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.2.0"
    }
  }
}

####### 環境変数から取得########
provider "aws" {}
