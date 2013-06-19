#!/bin/sh

yum install sudo vim libicu-devel -y
gem install charlock_holmes --version '0.6.9.4'

useradd -U -d /home/git -c "GitLab" git
echo "git  ALL=(ALL)  ALL" >> /etc/sudoers

sudo su git
cd /home/git
git clone https://github.com/gitlabhq/gitlab-shell.git
cd gitlab-shell
git checkout v1.5.0
cp config.yml.example config.yml
./bin/install


mysql -e "CREATE USER 'gitlab'@'localhost' IDENTIFIED BY 'eeL7owed';"
mysql -e "CREATE DATABASE IF NOT EXISTS gitlabhq DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql -e "GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON gitlabhq.* TO gitlab@localhost;"
mysql -e "FLUSH PRIVILEGES;"


cd /home/git

sudo -u git -H git clone https://github.com/gitlabhq/gitlabhq.git gitlab
cd /home/git/gitlab
sudo -u git -H git checkout 5-2-stable
sudo -u git -H cp config/gitlab.yml.example config/gitlab.yml

chown -R git log/
chown -R git tmp/
chmod -R u+rwX  log/
chmod -R u+rwX  tmp/

sudo -u git -H mkdir /home/git/gitlab-satellites

sudo -u git -H mkdir tmp/pids/
sudo -u git -H mkdir tmp/sockets/
chmod -R u+rwX  tmp/pids/
chmod -R u+rwX  tmp/sockets/

sudo -u git -H mkdir public/uploads
chmod -R u+rwX  public/uploads

sudo -u git -H cp config/puma.rb.example config/puma.rb
sudo -u git -H git config --global user.name "GitLab"
sudo -u git -H git config --global user.email "gitlab@localhost"

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
