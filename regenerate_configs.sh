#!/usr/bin/env bash

rm -rf /etc/pmta
rm -rf /etc/pmta/virtualhost.txt

curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/9-PMTA-Config.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/10-PMTA-Install.sh | bash

curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/set_pmta_config.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/set_virtualhost2.sh | bash

service pmta reload
service pmta restart
service pmta status

echo ' ';
echo '|\  ||  /|';
echo '--  ||  --';
echo '|/__/\__\|';
echo '    \/';
