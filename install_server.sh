#!/usr/bin/env bash

#mirror
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/install_mirror.sh | bash

curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/1-Start.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/2-LAMP.sh | bash

#domains.txt and mailpass
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/set_domains.sh | bash
#configurate nano set_domains.php
php set_domains.php
rm -rf set_domains.php

curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/3-BIND.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/4-Postfix.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/5-Exim.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/6-Dovecot.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/7-Roundcube.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/8-Zip.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/9-PMTA-Config.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/10-PMTA-Install.sh | bash

curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/change_server_port_1122.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/set_pmta_config.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/set_virtualhost.sh | bash

curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/set_date.sh | bash

service pmta reload
service pmta restart
service pmta status

echo ' ';
echo '|\  ||  /|';
echo '--  ||  --';
echo '|/__/\__\|';
echo '    \/';
