#!/bin/sh

yum install nginx redis -y

gem install rake
gem install rails
gem install mysql2
gem install rmagick
gem install vpim

gem install charlock_holmes --version '0.6.9.4'

# ---------------------------------------------------------------------------------------------

cd /home
git clone https://github.com/edavis10/redmine.git

cd /home/redmine
git checkout 2.3-stable
git pull

mysql -e "CREATE DATABASE redmine CHARACTER SET utf8;"
mysql -e "CREATE USER 'redmine'@'localhost' IDENTIFIED BY 'yoo9Uphe';"
mysql -e "GRANT ALL PRIVILEGES ON redmine.* TO 'redmine'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

cat << 'EOF' > config/database.yml
production:
  adapter: mysql2
  database: redmine
  host: localhost
  username: redmine
  password: yoo9Uphe
EOF

bundle install --without development test
rake generate_secret_token
RAILS_ENV=production rake db:migrate
RAILS_ENV=production REDMINE_LANG=ru rake redmine:load_default_data

mkdir -p tmp tmp/pdf public/plugin_assets
chmod -R 777 files log tmp public/plugin_assets

cd /home/redmine/plugins

wget -c http://redminecrm.com/license_manager/4200/redmine_issue_checklist-2_0_5.zip && \
unzip redmine_issue_checklist-2_0_5.zip && \
rm -f redmine_issue_checklist-2_0_5.zip

wget -c http://redminecrm.com/license_manager/4122/redmine_people-0_1_6.zip && \
unzip redmine_people-0_1_6.zip && \
rm -f redmine_people-0_1_6.zip

wget -c https://bitbucket.org/haru_iida/redmine_theme_changer/downloads/redmine_theme_changer-0.1.0.zip && \
unzip redmine_theme_changer-0.1.0.zip && \
rm -f redmine_theme_changer-0.1.0.zip

git clone https://github.com/iRessources/AgileDwarf.git
rake redmine:plugins:migrate RAILS_ENV=production

cd /home/redmine/public/themes/

wget -c http://redminecrm.com/license_manager/5340/a1-1_1_1.zip && \
unzip a1-1_1_1.zip && \
rm -f a1-1_1_1.zip

wget -c http://redminecrm.com/license_manager/3918/highrise_tabs-1_1_1.zip
unzip highrise_tabs-1_1_1.zip && \
rm -f highrise_tabs-1_1_1.zip

wget -c http://redminecrm.com/license_manager/3917/highrise-1_1_1.zip && \
unzip highrise-1_1_1.zip && \
rm -f highrise-1_1_1.zip

wget -c http://redminecrm.com/license_manager/4508/coffee-0_0_3.zip && \
unzip coffee-0_0_3.zip && \
rm -f coffee-0_0_3.zip

wget -c http://redminecrm.com/license_manager/3834/redminecrm-0_0_1.zip && \
unzip redminecrm-0_0_1.zip && \
rm -f redminecrm-0_0_1.zip

git clone https://github.com/pixel-cookers/redmine-theme.git pixel-cookers

cd /home/redmine

# ------------------------------------------------------------------------

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
