#!/bin/sh

curl -O http://www6.atomicorp.com/channels/atomic/centos/6/x86_64/RPMS/atomic-release-1.0-14.el6.art.noarch.rpm
rpm -Uvh atomic-release-1.0-14.el6.art.noarch.rpm
rpm -Uvh http://rbel.co/rbel5

yum update -y
yum groupinstall "Development Tools" -y
yum install libyaml-devel mysql mysql-devel mysql-lib ImageMagick-devel ImageMagick-c++-devel httpd libtool httpd-devel apr-devel apr curl-devel-y

curl -L https://get.rvm.io | bash
source /etc/profile

su -

type rvm | head -n 1

rvm pkg install libyaml
rvm requirements
rvm install 1.9.3
rvm use 1.9.3 --default
rvm rubygems current

gem install bundler
gem install rake
gem install rails
gem install mysql2
gem install rmagick
gem install vpim
