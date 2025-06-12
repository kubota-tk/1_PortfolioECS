# 1_PortfolioECSについて
&emsp;AWSのクラウドインフラ環境構築と、アプリケーションのデプロイを自動構築した。  
&emsp;プライベートなECS Fargate(アプリケーションコンテナ,nginxコンテナ)、RDS(MySQL)によるサーバー3層構造に、Railsを使用したCRUDアプリケーションをデプロイしたもので、同アプリケーションに投稿した画像はS3に保存される。アプリ管理者用の踏み台EC２実装や、システムエラー時のCloudWatchアラームによるメール通知機能がある。


## 概要の詳細

* 本クラウドインフラ環境構築は、GitHubへのPushをトリガーに、CircleCIのWorkFromを使って「Terraform」,「Ansible」,「ServerSpec」で自動構築が行われる。  
* Terraformでは、CRUD操作が可能なRailsのWEBアプリケーションを動作させるための、AWS環境（「ECS Fargate(app_containerコンテナ,nginx_containerコンテナ)」,「RDS(MySQL)」,「ALB」,「S3」,「CloudWatch」,「SNS」,「EC2(踏台用)」,「VPC」)を作成する。  
* Webアプリケーションの設定ファイルは「raisetech-live8-sample-appディレクトリ」に格納されている。同ディレクトリに保存されているDockerfileとコマンドを使って、既に自動構築されたECRへイメージPushする。
* Ansibleでは、EC2（踏み台用）内のセットアップを構築する。WEBアプリケーションの管理者は、同EC2にSSH接続し、「ECRリポジトリへのイメージPush」,「ECS Fargateの各コンテナへのECS Exec通信」,「画像保管用S3へのアクセス」が可能となる。  
* ServerSpecでは、EC2（踏み台用）のセットアップ状況のテストを実施する。  
* ECS Fargateはプライベート環境で構築され、外部通信にVPCエンドポイントを使用する。app_container(Pumaサーバー、WEBアプリケーションのデプロイ)とnginx_container（WEBサーバー）の2つのコンテナで実装される。    
&emsp;CPU使用率75%以上でコンテナのスケールアウト、CPU使用率25%以下でコンテナのスケールインを行う。  
* ECS Fargateの状態監視をALB,ターゲットグループで行い、通信異常が発生した場合はCloudWatchアラーム通知,SNSでメール送信を行う。


&emsp;構成図  
![0.1_構成図](images/0.1_構成図.png)  
&emsp;VPCリソースマップ
![0.2_vpc_map](images/0.2_vpc_map.png) 


## 1. CircleCIによる環境変数・SSH Key設定と、実行状況  
&emsp;CircleCI上で、環境変数（AWSへの接続,Terraform・Ansible・ServerSpec各々に必要な環境変数）とSSH Key設定を実施。
   
&emsp;CIrcleCIの環境変数設定
![1.1_circleci1](images/1.1_circleci1.png)
![1.2_circleci2](images/1.2_circleci2.png)  
  
&emsp;CircleCIのSSH Key設定
![1.3_circleci3](images/1.3_circleci3.png)  
  
&emsp;CircleCIのworkfrow実行状況  
![1.4_circleci4](images/1.4_circleci4.png)
  

template
- [**config.yml**](/.circleci/config.yml)


## 2. Terraformの各モジュール設定
- ルートモジュールをenv/devに作成。開発環境と本番環境でルートモジュールを分けることができ、ルートモジュールから、子モジュールを呼び出せるよう、下図のディレクトリ構成とした。
  
&emsp;CircleCIのTerraform実行状況  
![2.1_terraform1](images/2.1_terraform1.png)  
  
&emsp;Terraformのディレクトリ構成
![2.2_terraform2](images/2.2_terraform2.png)  

template
- [**dev/main.tf(ルートモジュール)**](/terraform/env/dev/main.tf)  
- [**alb/main.tf**](/terraform/modules/alb/main.tf) 
- [**clouwatch/main.tf**](terraform/modules/cloudwatch/main.tf)  
- [**ec2/main.tf**](/terraform/modules/ec2/main.tf)
- [**ecr/main.tf**](/terraform/modules/ecr/main.tf)
- [**ecs/main.tf**](/terraform/modules/ecs/main.tf)
- [**rds/main.tf**](/terraform/modules/rds/main.tf)
- [**s3/main.tf**](/terraform/modules/s3/main.tf)
- [**security_group/main.tf**](/terraform/modules/security_group/main.tf)
- [**sns/main.tf**](/terraform/modules/sns/main.tf)
- [**vpc/main.tf**](/terraform/modules/vpc/main.tf)


## 3. Ansibleのセットアップ設定
- EC2（踏み台）に必要な各種ツールのインストールや設定を実行。  
  
&emsp;CircleCIのAnsible実行状況  
![3.1_ansible1](images/3.1_ansible1.png)  
![3.2_ansible2](images/3.2_ansible2.png) 
    
&emsp;Ansibleのディレクトリ構成 
![3.3_ansible3](images/3.3_ansible3.png) 

Template(Ansibleの設定ファイル）
 - [**inventory.yml**](/ansible/inventory)  
 - [**playbook.yml**](/ansible/playbook.yml)  
 - [**main.yml(aws-cli)**](/ansible/roles/aws-cli/tasks/main.yml) 
 - [**main.yml(docker)**](/ansible/roles/docker/tasks/main.yml)     
 - [**main.yml(exec)**](/ansible/roles/exec/tasks/main.yml)     
 - [**main.yml(git)**](/ansible/roles/git/tasks/main.yml)     
 - [**main.yml(swap)**](/ansible/roles/swap/tasks/main.yml)      


## 4. ServerspecによるEC2セットアップ状況のテスト
「gitのインストール状況」,「S3へのアクセス確認」,「SessionManagerのPluginインストール状況」,「Dockerの起動確認」をテスト。  
  
&emsp;CircleCIのServerspec実行状況
![4.1_serverspec1](images/4.1_serverspec1.png)  
![4.2_serverspec2](images/4.2_serverspec2.png)
![4.3_serverspec3](images/4.3_serverspec3.png)

template
 - [**Gemfile**](/serverspec/Gemfile)  
 - [**sample_spec.rb**](/serverspec/sample_spec.rb)
  
  
## 5. ECRへのイメージプッシュ  
&emsp;Webアプリケーションの設定ファイルは「raisetech-live8-sample-appディレクトリ」に格納されている。  
&emsp; ECRへのイメージPushは、自動構築されたECRリポジトリに対して、コマンドで実行する。使用するDockerfileの保存場所は以下のとおり。
- 「app_container（/raisetech-live8-sample-app/Dockerfile）」
- 「nginx_container（/raisetech-live8-sample-app/nginx/Dockerfile）」
    
&emsp;ECRに自動構築されたリポジトリ
![5.1_image_push1](images/5.1_image_push1.png)
  
&emsp;ECRへのイメージPushコマンド
![5.2_image_push2](images/5.2_image_push2.png)

template
 - [**app_containerのDockerfile（/raisetech-live8-sample-app/Dockerfile）**](/raisetech-live8-sample-app/Dockerfile)
 - [**nginx_containerのDockerfile（/raisetech-live8-sample-app/nginx/Dockerfile）**](/raisetech-live8-sample-app/nginx/Dockerfile)
  
  
## 6. EC2（踏み台用）の各種機能
(1) ECRにイメージがPushできることの確認  
&emsp;ECRに確認用のsampleリポジトリを作成  
![6.1_EC2_1](images/6.1_EC2_1.png)  

&emsp;EC2にSSH接続し、イメージ作成用のDockerfileを作成  
![6.2_EC2_2](images/6.2_EC2_2.png)   
  
&emsp;EC2で作成したイメージをECRにプッシュする      
![6.3_EC2_3](images/6.3_EC2_3.png)  
  
(2) ECS FargateへECS Exec通信ができることの確認  
&emsp;EC2にSSH接続し、ECS Execでコンテナに接続、コマンドを実行  
![6.4_EC2_4](images/6.4_EC2_4.png)  
  
(3) アプリの画像保管場所、S3バケットに接続できることの確認  
&emsp;EC2にSSH接続し、awsコマンドでバケットの内部データを確認                         
![6.4_EC2_5](images/6.5_EC2_5.png)  
  
  
## 7. Fargateのコンテナとスケーリングの確認   
&emsp;ECS Fargateのタスクと、コンテナ（app_container、nginx_container）作成状況。  
![7.1_ECS_1](images/7.1_ECS_1.png)   
![7.2_ECS_2](images/7.2_ECS_2.png)   
  
&emsp;ECSのスケーリング設定と、実際にスケールアウト、インが実行された記録。  
![7.3_ECS_3](images/7.3_ECS_3.png)   
  
&emsp;スケールアウトのアラーム内容（CPU使用率75%以上の場合実施） 
![7.4_ECS_4](images/7.4_ECS_4.png)

&emsp;スケールインのアラーム内容（CPU使用率25%より小さい場合実施）                 
![7.5_ECS_5](images/7.5_ECS_5.png)   
  
&emsp;ECS サービス画面から、スケールアウトでタスクが2個に増えた時の状況を確認。    
![7.6_ECS_6](images/7.6_ECS_6.png)  
![7.7_ECS_7](images/7.7_ECS_7.png)  
  
    

## 8. ECSに通信異常が発生した場合のアラーム通知   
&emsp;ECS Fargateの通信状態を確認するALBと、ターゲットグループ。  
![8.1_ararm1](images/8.1_ararm1.png)   
![8.2_ararm2](images/8.2_ararm2.png)  
  
&emsp;CloudWatchアラーム通知と、送信されたメールの内容。
![8.3_ararm3](images/8.3_ararm3.png)  
![8.4_ararm4](images/8.4_ararm4.png)  
  

    
## 9. アプリの実行状況確認
&emsp;自動デプロイした Webアプリケーションに、ALBのDNS名を使ってブラウザーから接続。画像を保存してS3に追加、削除されるまでを確認した。  
- Webアプリケーションのトップページを表示    
![9.1_app_run1](images/9.1_app_run1.png)  
  
- アプリに画像を追加した状況でのトップページ 
![9.2_app_run2](images/9.2_app_run2.png)    

- S3に画像が保存された状況 
![9.3_app_run3](images/9.3_app_run3.png)    

- S3の画像を表示した状況  
![9.4_app_run4](images/9.4_app_run4.png)    

- アプリで画像を削除し
![9.5_app_run5](images/9.5_app_run5.png)    
 
- S3の画像も削除が反映された状況
![9.6_app_run6](images/9.6_app_run6.png)    

## 10. 考察、その他参考
&emsp;CI/CDでの環境構築を実現するため、TerraformやAnsibleによるコード化や、コンテナ利用によるサーバレス化を想定してECS（Fargate）を導入し、ポートフォリオを作成した。本環境構築において、以下のとおり考察して行った。
- 今回はクラウドインフラ環境の構築画面となっているため、Webアプリケーションについては簡易なものとなっている。また、マルチAZ構成による冗長化がベストプラクティスであるが、費用面から一部省略している。  
- セキュリティーグループ設定においては、CircleCIの無料版を使用している都合上、パブリックIPアドレス設定部分を0.0.0.0（オール）で実行可能にしている。
- ECS Exec通信を行えば、踏み台EC2を作らなくてもダイレクトにFargateコンテナに通信できるが、今回は自分のPC環境を使いたくない場合や、環境構築の経験として、敢えて踏み台用EC2を作成した。
- 踏み台EC2への通信をSessionManagerで行った方が22番ポートを開かなくて済むため、よりセキュアになるが、VPCエンドポイントの作成件数が増え、費用対効果の面であえてSSH通信とした。
-  プライベートなFargateからの外部通信にNATゲートウェイも活用できるが、ECRからのイメージ取得が頻繁に行われる場合など、転送料金が大きくなる場合があり、VPCエンドポイントでの設計を行なった。

