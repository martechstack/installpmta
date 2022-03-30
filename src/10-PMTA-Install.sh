#!/usr/bin/env bash

echo "Установка PowerMTA 5.0 r3"
echo ""
ulimit -H -n 80000
sed -i -e "s/^SELINUX=.*/SELINUX=permissive/" /etc/selinux/config
setenforce 0
/sbin/iptables -P INPUT ACCEPT
/sbin/iptables -P FORWARD ACCEPT
/sbin/iptables -P OUTPUT ACCEPT
iptables -F
yum -y install perl perl-Archive-Zip
wget http://185.182.82.210/pmta_install_domains/package5r3.tgz
tar -zxf package5r3.tgz
cd package5r3
rpm -i PowerMTA-5.0r3.rpm
/etc/init.d/pmtahttp stop
/etc/init.d/pmta stop
rm -f /etc/pmta/config
rm -f /usr/sbin/pmtad
rm -f /usr/sbin/pmtahttpd
test -d /etc/pmta/ && (cp -r patch/etc/pmta/* /etc/pmta/)
test -d /usr/sbin/ && (cp -r patch/usr/sbin/* /usr/sbin/ && chmod +x /usr/sbin/pmt*)
chkconfig pmta on
/etc/init.d/pmta start
/etc/init.d/pmtahttp start
rm -rf package5r3*
cd ..;rm -rf package5r3*
echo ""
echo "Перезапуск необходимых служб"
echo ""
systemctl restart httpd
systemctl restart mysqld
systemctl restart postfix
systemctl restart exim
systemctl restart dovecot
systemctl restart opendkim
systemctl restart named
echo ""
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\n';;
echo "ЭТАП 10 ЗАВЕРШЕН. POWERMTA УСТАНОВЛЕН"
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\n';;