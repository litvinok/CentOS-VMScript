#!/bin/sh

yum install sudo vim -y

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
