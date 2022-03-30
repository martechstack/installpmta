#!/usr/bin/env bash

archname=site.zip
yum -y install unzip
wget http://185.182.82.210/site/$archname
rm -f /tmp/vh
rm -f /tmp/vline
while read line
do
echo $line > /tmp/vline
echo "`cat /tmp/vline | awk '{print $1}'`"> /tmp/vh
enddir=`cat /tmp/vh`
mkdir /var/www/$enddir
done < /root/domains.txt
rm -f /tmp/vh
rm -f /tmp/vline
while read line
do
echo $line > /tmp/vline
echo "`cat /tmp/vline | awk '{print $1}'`"> /tmp/vh
enddir=`cat /tmp/vh`
unzip $archname -d /var/www/$enddir
done < /root/domains.txt
sleep 5
chown -R apache:apache /var/www
echo "Подготовка файловой системы сервера завершена"
echo ""
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\n';;
echo "ЭТАП 8 ЗАВЕРШЕН"
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\n';;