#!/bin/sh

yum install mysql-server -y
service mysqld start

cd /home
git clone https://github.com/edavis10/redmine.git

cd redmine
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
