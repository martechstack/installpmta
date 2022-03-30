#!/usr/bin/env bash

yum -y install httpd
systemctl enable httpd && systemctl start httpd
rm -f /tmp/vh
while read line
do
echo $line > /tmp/vline
echo "#`cat /tmp/vline | awk '{print $1}'`">> /tmp/vh
#echo "NameVirtualHost `cat /tmp/vline | awk '{print $2}'`":80>> /tmp/vh
echo "<VirtualHost `cat /tmp/vline | awk '{print $2}'`:80>">> /tmp/vh
echo "DocumentRoot /var/www/`cat /tmp/vline | awk '{print $1}'`" >> /tmp/vh
echo "ServerName `cat /tmp/vline| awk '{print $1}'`" >> /tmp/vh
echo "</VirtualHost>">> /tmp/vh
echo " ">> /tmp/vh
done < /root/domains.txt
cat /tmp/vh >> /etc/httpd/conf/httpd.conf
cat << 'EOF' >> /etc/httpd/conf/httpd.conf
<Directory "/var/www">
    AllowOverride All
    # Allow open access:
    Require all granted
</Directory>
<Directory />
    Options FollowSymLinks
    AllowOverride All
    Allow from All
</Directory>
EOF
systemctl restart httpd
echo "Apache успешно установлен"
yum -y install mariadb-server
yum -y install mariadb-client
systemctl enable mariadb && systemctl start mariadb
echo "MySQL успешно установленна"
yum -y install php php-mysqlnd php-pear* php-common php-mbstring php-devel php-xml php-gd php-intl php-json php-zip
echo -ne "\n" | pecl install mcrypt-1.0.1
cat <<'EOF' > /etc/php.d/20-mcrypt.ini
extension=mcrypt.so
EOF
echo "PHP успешно установлен"
echo "LAMP успешно установлен"
echo ""
echo "Установка пакетов OpenDKIM"
rm -f /etc/opendkim.conf
cat <<'EOF' > /etc/opendkim.conf

PidFile /var/run/opendkim/opendkim.pid
Mode    sv
Syslog  yes
SyslogSuccess   yes
LogWhy  yes
UserID  opendkim:opendkim
Socket  inet:8891@localhost
Umask   002
SendReports     yes
SoftwareHeader  yes
RequireSafeKeys false
Canonicalization        relaxed/relaxed
Selector        dkim5
MinimumKeyBits  1024
KeyFile /etc/opendkim/keys/default.private
KeyTable            /etc/opendkim/KeyTable
SigningTable        refile:/etc/opendkim/SigningTable
ExternalIgnoreList  refile:/etc/opendkim/TrustedHosts
InternalHosts       refile:/etc/opendkim/TrustedHosts
OversignHeaders From
EOF

while read line
do
IFS=' '
read -ra domain <<< "$line"

echo "*@${domain[0]}    dkim5._domainkey.${domain[0]}" >> /etc/opendkim/SigningTable
echo "dkim5._domainkey.${domain[0]}    ${domain[0]}:dkim5:/etc/dkim.key" >> /etc/opendkim/KeyTable
echo "*.${domain[0]}" >> /etc/opendkim/TrustedHosts
done < /root/domains.txt

systemctl enable opendkim
systemctl restart opendkim

systemctl start httpd
echo ""
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\n';;
echo "ЭТАП 2 ЗАВЕРШЕН"
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\n';;
echo ""