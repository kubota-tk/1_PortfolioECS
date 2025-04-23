######## backend ########
## tfstateファイルを管理するようbackend(s3)を設定 

terraform {
  backend "s3" {
    bucket  = "terraform-tfstat-management"
    key     = "PortfolioECS-playground.tfstate"
    region  = "ap-northeast-1"
    encrypt = "true"
  }

## localhostで管理する場合 ##
##  backend "local" {
##    path   = "terraform.tfstate"
##  }

}

