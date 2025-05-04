require 'spec_helper'

#gitのインストール確認
describe package('git') do
  it { should be_installed }
end

#22番ポートの疎通確認
describe port(22) do
  it { should be_listening.with('tcp') }
end

#awsコマンド、s3確認ができるか
describe command('sudo aws s3 ls') do
  its(:stdout) { should match /portfolio-ecs-picture/ }
end

#ECS Exec使用のため、SessionManagerPluginのインストール確認
describe command('session-manager-plugin') do
  its(:stdout) { should match /The Session Manager plugin was installed successfully/ }
end

#dockerが起動していることの確認
describe service('docker') do
  it { should be_enabled   }
  it { should be_running   }
end

