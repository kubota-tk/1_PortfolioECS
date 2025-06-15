# Terraformの概要
- Terraformを活用し、AWS環境（「ECS Fargate(app_containerコンテナ,nginx_containerコンテナ)」,「RDS(MySQL)」,「ALB」,「S3」,「CloudWatch」,「SNS」,「EC2(踏台用)」,「VPC」)を作成
- ECS（Fargate）、RDSで、サーバー３層構造、ALBで分散環境に対応
- S3で、CRUDアプリの画像保管が可能
- ECS（Fargate）にスケールアウト、スケールイン設定
- CloudWatchとSNSで、EC2とALB間の通信異常を検知、アラーム通知が可能

## 開発環境について
- 開発環境(terraform/env/dev)と本番環境（terraform/env/prod）に環境を分けた
- terraform/modules内の子モジュールは、環境env内のルートモジュールmain.tfから呼び出す。
- AWS接続に必要な環境変数は、別ファイルで設定
- backend設定はs3に設定
- 環境変数はterraform.tfvarsで設定

## ディレクトリの作業環境の構成がわかる図  
  
<img src="../images/2.2_terraform2.png" width="50%">


