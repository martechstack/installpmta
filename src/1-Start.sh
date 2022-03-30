#!/usr/bin/env bash

echo "Производится начальная подготовка сервера..."
echo ""
# установка пререквизитов
yum -y install epel-release
yum -y update
yum -y install make
yum -y install libmcrypt-devel
yum -y install autoconf pkg-config
yum -y install wget
yum -y install which
yum -y install unzip
echo "Репозитории обновлены. Подготовка завершена"
systemctl stop firewalld && systemctl disable firewalld
echo ""
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||';echo '';;
echo "ЭТАП 1 ЗАВЕРШЕН"
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||';echo '';;
