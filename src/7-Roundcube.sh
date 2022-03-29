#!/usr/bin/env bash

yum -y install php-zip
pear install Mail_Mime
pear install Net_SMTP
mysql -u root << 'EOF'
CREATE DATABASE IF NOT EXISTS `roundcube`;
CREATE USER 'roundcube'@'localhost' IDENTIFIED BY 'roundcube';
GRANT ALL PRIVILEGES ON `roundcube` . * TO 'roundcube'@'localhost';
FLUSH PRIVILEGES;
EOF
touch /etc/httpd/conf.d/90-roundcube.conf
cat << 'EOF' > /etc/httpd/conf.d/90-roundcube.conf
Alias /webmail /var/www/html/roundcube

<directory /var/www/html/roundcube>
    Options -Indexes
    AllowOverride All
</directory>

<directory /var/www/html/roundcube/config>
    Order Deny,Allow
    Deny from All
</directory>

<directory /var/www/html/roundcube/temp>
    Order Deny,Allow
    Deny from All
</directory>

<directory /var/www/html/roundcube/logs>
    Order Deny,Allow
    Deny from All
</directory>
EOF
curl -L "https://github.com/roundcube/roundcubemail/releases/download/1.4.9/roundcubemail-1.4.9.tar.gz" > /tmp/roundcube-latest.tar.gz
#curl -L "http://sourceforge.net/projects/roundcubemail/files/latest/download?source=files" > /tmp/roundcube-latest.tar.gz
tar -zxf /tmp/roundcube-latest.tar.gz -C /var/www/html
rm -f /tmp/roundcube-latest.tar.gz
mv /var/www/html/roundcubemail-* /var/www/html/roundcube
chown root: -R /var/www/html/roundcube/
chown apache: -R /var/www/html/roundcube/temp/
chown apache: -R /var/www/html/roundcube/logs/
mysql -u roundcube -p"roundcube" roundcube < /var/www/html/roundcube/SQL/mysql.initial.sql
cp /var/www/html/roundcube/config/config.inc.php.sample /var/www/html/roundcube/config/config.inc.php
sed -i "s|^\(\$config\['db_dsnw'\] =\).*$|\1 \'mysql://roundcube:roundcube@localhost/roundcube\';|" /var/www/html/roundcube/config/config.inc.php
sed -i "s|^\(\$config\['smtp_server'\] =\).*$|\1 \'localhost\';|" /var/www/html/roundcube/config/config.inc.php
sed -i "s|^\(\$config\['smtp_user'\] =\).*$|\1 \'%u\';|" /var/www/html/roundcube/config/config.inc.php
sed -i "s|^\(\$config\['smtp_pass'\] =\).*$|\1 \'%p\';|" /var/www/html/roundcube/config/config.inc.php
/var/www/html/roundcube/bin/install-jsdeps.sh
setsebool -P httpd_can_network_connect 1
systemctl restart httpd
echo "Roundcube успешно установлен"
echo ""
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||';
echo "ЭТАП 7 ЗАВЕРШЕН"
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||';