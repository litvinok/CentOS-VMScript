#!/bin/sh

#rpm -ivh http://centos.alt.ru/repository/centos/5/i386/centalt-release-5-3.noarch.rpm

rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/gperftools-libs-2.0-11.el6.1.x86_64.rpm
rpm -ivh http://centos.alt.ru/repository/centos/6/x86_64/redis-2.6.13-1.el6.x86_64.rpm
yum install sudo vim libicu-devel redis -y
gem install charlock_holmes --version '0.6.9.4'
  
useradd -U -d /home/git -c "GitLab" git
echo "git  ALL=(ALL)  ALL" >> /etc/sudoers

sudo su git
cd /home/git
git clone https://github.com/gitlabhq/gitlab-shell.git
cd gitlab-shell
git checkout v1.4.0
cp config.yml.example config.yml
./bin/install


mysql -e "CREATE USER 'gitlab'@'localhost' IDENTIFIED BY 'eeL7owed';"
mysql -e "CREATE DATABASE IF NOT EXISTS gitlabhq DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql -e "GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON gitlabhq.* TO gitlab@localhost;"
mysql -e "FLUSH PRIVILEGES;"


cd /home/git

git clone https://github.com/gitlabhq/gitlabhq.git gitlab
cd /home/git/gitlab
git checkout 5-2-stable
cp config/gitlab.yml.example config/gitlab.yml

chown -R git log/
chown -R git tmp/
chmod -R u+rwX  log/
chmod -R u+rwX  tmp/

mkdir /home/git/gitlab-satellites

mkdir tmp/pids/
mkdir tmp/sockets/
chmod -R u+rwX  tmp/pids/
chmod -R u+rwX  tmp/sockets/

mkdir public/uploads
chmod -R u+rwX  public/uploads

cp config/puma.rb.example config/puma.rb
git config --global user.name "GitLab"
git config --global user.email "gitlab@localhost"

cat << 'EOF' > config/database.yml
production:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: gitlabhq
  pool: 5
  username: gitlab
  password: eeL7owed
EOF

cd /home/git/gitlab
bundle install --deployment --without development test postgres
bundle exec rake gitlab:setup RAILS_ENV=production
