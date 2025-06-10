# 1_PortfolioECSについて
&emsp;AWSのクラウドインフラ環境を自動構築した。プライベートなECS(pumaコンテナ,nginxコンテナ)、RDS(MySQL)の3層構造に、画像のCRUD操作ができるWebアプリケーションをデプロイし、同アプリケーションで投稿した画像はS3保管され、エラー時にはCloudwatchのアラーム通知が発生する。


## 概要

* CRUD操作が可能なRailsのWEBアプリケーションを動作させるため、AWSのクラウドインフラ環境(ECS(pumaコンテナ,nginxコンテナ)RDS(MySQL)、ALB,S3,CloudWatch,SNS,EC2(踏台用))を、Terraform,CircleCI,Ansible,ServerSpec,GitHubを使って自動構築した。
* ECSはプライベートな設定にしており、外部接続にはVPCエンドポイントを使用。WEBアプリケーションのデプロイはDokerfileに記載し、pumaコンテナとnginxコンテナ、RDSで行った。
* ECSは、CPU使用率75%以上でコンテナの追加を、CPU使用率25%以下でコンテナの削除を行う。
* ECSの起動に異常が発生した場合、CloudWatchとSNSを使って、メールでアラーム通知を送信する。
* SSH接続で踏台用EC2に入り、ECRリポジトリへのイメージ作成、ECSコンテナ調整のためのECS Exec通信を可能とした。同EC2の環境構築はAnsibleを使用して自動構築した。
  
![0.1_構成図](images2/0.1_構成図.png)  


## 1. Terraformの各モジュール作成
- ルートモジュールをenv/devに作成。開発環境と本番環境でルートモジュールを分けることができ、ルートモジュールから、子モジュールを呼び出せるよう、下図のディレクトリ構成とした。
  
![1.1_terraform](images3/1.1_terraform.png)  

template
- [**dev/main.tf**](/template3/terraform/env/dev/main.tf)  
- [**alb/main.tf**](/template3/terraform/modules/alb/main.tf) 
- [**clouwatch/main.tf**](/template3/terraform/modules/cloudwatch/main.tf)  
- [**ec2/main.tf**](/template3/terraform/modules/ec2/main.tf)
- [**iam/main.tf**](/template3/terraform/modules/iam/main.tf)
- [**rds/main.tf**](/template3/terraform/modules/rds/main.tf)
- [**s3/main.tf**](/template3/terraform/modules/s3/main.tf)
- [**security_group/main.tf**](/terraform/modules/security_group/main.tf)
- [**sns/main.tf**](/template3/terraform/modules/sns/main.tf)
- [**vpc/main.tf**](/template3/terraform/modules/vpc/main.tf)

## 2. CircleCIに環境変数を設定  
&emsp;CircleCI上で、環境変数「AWS_ACCESS_KEY_ID」「AWS_DEFAULT_REGION」「AWS_SECRET_ACCESS_KEY」を設定した。

![1.1_environment](images2/1.1_environment.png)  

template
- [**config.yml（terraformの自動実行jobを追加）**](/template3/circleci/config.yml)

## 3. Ansibleのアプリ等のセットアップ設定
Railsアプリケーションのインストールに必要なツールのインストールと、サーバーテンプレートの設定変更を実行。（前回と変更なし）
![3.1_ansible](images3/3.1_ansible.png)  
![3.2_ansible](images3/3.2_ansible.png) 

Template(Ansibleの設定ファイル）
 - [**inventory.yml**](/template3/ansible/inventory)  
 - [**playbook.yml**](/template3/ansible/playbook.yml)  
 - [**main.yml(swap)**](/template3/ansible/roles/swap/tasks/main.yml)  


## 4. Serverspecのテスト
git,nginxのインストール確認（前回と変更なし）
![4.1_serverspec](images3/4.1_serverspec.png)  
![4.2_serverspec](images3/4.2_serverspec.png)

template（前回と変更なし）
 - [**Gemfile**](/template3/serverspec/Gemfile)  
 - [**sample_spec.rb**](/template3/serverspec/sample_spec.rb)


## 5. アプリの実行状況確認
1. 自動デプロイした Webアプリケーションに、ALBのDNS名を使ってブラウザーから接続。画像を保存してS3に追加、削除されるまでを確認した。  
- Webアプリケーションのトップページを表示    
![5.1_app_top_page](images3/5.1_app_top_page.png)  
  
- アプリに画像を追加させて表示
![5.2_app_pic_create](images3/5.2_app_pic_create.png)

- S3に画像が保存された状況  
![5.3_app_s3_create](images3/5.3_app_s3_create.png)

- S3の画像を表示した状況  
![5.4_app_s3_detail](images3/5.4_app_s3_detail.png)

- アプリで画像を削除した状況
![5.5_app_pic_delete](images3/5.5_app_pic_delete.png)
 
- S3の画像も削除が反映された状況
![5.6_app_s3_delete](images3/5.6_app_s3_delete.png)

2. アラームの通知がEmail宛に送られることを確認した。  
- VPCからネットワークの様子を確認
![5.7_app_alart_check](images3/5.7_app_alart_check.png)

- ALBターゲットグループからネットワークが正常な状況を確認
![5.8_app_alart_check](images3/5.8_app_alart_check.png)

- 意図的にネットワークに異常を発生させた状況をアラーム詳細画面から確認
![5.9_app_alart_check](images3/5.9_app_alart_check.png)

- SNS Topicで設定した通知用メールアドレスに通知が来る様子を確認
![5.10_app_alart_check](images3/5.10_app_alart_check.png)

## 6. 考察、その他参考
&emsp;今回はブラウザーからURL入力を判断してAPI GatewayがLambdaを起動、DynamoDBを操作するサービスを構築した。AWSによる環境構築がメインのため、現段階ではテーブルの読み取りしか行えない。また、REST API以外にHTTP APIがあるなど、サービスや連携させるアプリによって様々な構築の仕方を工夫する必要がある。
