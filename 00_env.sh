#!/bin/sh

rpm -Uvh http://www6.atomicorp.com/channels/atomic/centos/6/x86_64/RPMS/atomic-release-1.0-14.el6.art.noarch.rpm
rpm -Uvh http://rbel.co/rbel5
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/gperftools-libs-2.0-11.el6.1.x86_64.rpm
rpm -ivh http://centos.alt.ru/repository/centos/6/x86_64/redis-2.6.13-1.el6.x86_64.rpm

yum update -y
yum groupinstall "Development Tools" -y
yum install libyaml-devel mysql mysql-server mysql-devel mysql-lib ImageMagick-devel ImageMagick-c++-devel libtool apr-devel apr curl-devel wget sudo vim libicu-devel -y

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

service mysqld start
