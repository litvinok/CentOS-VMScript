#!/bin/sh

yum install wget mysql-server -y
service mysqld start

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

gem install thin
gem install daemons
gem install eventmachine
gem install cgi_multipart_eof_fix
gem install action_mailer_tls
gem install activerecord-mysql-adapter

mkdir /etc/thin
cat << 'EOF' > /etc/thin/redmine.yml
pid: tmp/pids/thin.pid
group: nginx
timeout: 30
log: log/thin.log
max_conns: 1024
environment: production
max_persistent_conns: 512
servers: 4
daemonize: true
user: nginx
socket: /tmp/thin.sock
chdir: /home/redmine
EOF

cat << 'EOF' > /etc/nginx/conf.d/redmine.conf
upstream thin_cluster {
    server unix:/tmp/thin.0.sock;
    server unix:/tmp/thin.1.sock;
    server unix:/tmp/thin.2.sock;
    server unix:/tmp/thin.3.sock;
}

server {
    listen       80;
    server_name  _;

    access_log  /var/log/nginx/redmine-proxy-access;
    error_log   /var/log/nginx/redmine-proxy-error;

    include conf.d/proxy.include;
    root /home/redmine/public;
    proxy_redirect off;

    location / {
        try_files $uri/index.html $uri.html $uri @cluster;
    }

    location @cluster {
        proxy_pass http://thin_cluster;
    }
}
EOF

chkconfig nginx on
chkconfig mysqld on
chkconfig thin on
