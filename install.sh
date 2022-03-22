#!/usr/bin/env bash
#3. create mailpass.txt
#4. create domains.txt

sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-*
yum check-update
yum update
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/1-Start.sh | bash