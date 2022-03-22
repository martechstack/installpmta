#!/usr/bin/env bash
#3. create mailpass.txt
#4. create domains.txt

sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-*
yum check-update
yum update
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/1-Start.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/2-LAMP.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/3-BIND.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/4-Postfix.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/5-Exim.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/6-Dovecot.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/7-Roundcube.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/8-Zip.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/9-PMTA-Config.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/10-PMTA-Install.sh | bash