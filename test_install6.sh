#!/usr/bin/env bash

#mirror
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/test_install_mirror.sh | bash

curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/1-Start.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/2-LAMP.sh | bash

#domains.txt and mailpass
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/test_set_domains.sh | bash
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

curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/test_change_server_port.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/test_set_config3.sh | bash

curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/test_set_date.sh | bash

#curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/test_set_virtualhost.sh | bash

service pmta reload
service pmta restart
service pmta status

echo ' ';
echo '|\  ||  /|';
echo '--  ||  --';
echo '|/__/\__\|';
echo '    \/';
