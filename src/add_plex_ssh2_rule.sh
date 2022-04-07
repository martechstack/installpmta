#!/usr/bin/env bash

config='config.json'
SERVER_IP=$(jq -r '.server_ip' "$config")
SSH2_FILE='/var/www/admin/data/www/plex.mailerapp.cc/vendor/phpseclib/phpseclib/phpseclib/Net/SSH2.php';

if grep -q ${SERVER_IP} ${SSH2_FILE};
then
    echo 'SERVER_IP already in file..';
else
  sed -i 's/function __construct($host, $port = 22, $timeout = 10) {/function __construct($host, $port = 22, $timeout = 10) {\n        if ($host == "'${SERVER_IP}'") { $port = 1122; }\n/g' ${SSH2_FILE}
  echo 'SERVER_IP added to ssh2 file';
fi

