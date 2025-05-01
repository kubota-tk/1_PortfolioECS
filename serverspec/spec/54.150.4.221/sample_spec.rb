require 'spec_helper'

#gitのインストール確認
describe package('git')do
 it { should be_installed }
end

#nginxのインストール確認
describe package('nginx') do
  it { should be_installed }
end


