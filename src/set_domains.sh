#!/usr/bin/env bash

#yum install epel-release -y
#yum install jq -y
#config='config.json'
#PMTA_DOMAIN=$(jq -r '.domain' "$config")

cat <<'EOF' >$HOME/set_domains.php
<?php

$config = json_decode(file_get_contents('config.json'));

$domain = $config->domain;
$server_ip = $config->server_ip;
$server_pass = $config->server_pass;
$ips = $config->ips;

//todo insert configs
$file = 'domains.txt';
$file_mailpass = 'mailpass.txt';

file_put_contents($file_mailpass, $server_pass);
file_put_contents($file, $domain . ' ' . $server_ip . PHP_EOL);
file_put_contents($file, 'a1.' .$domain . ' ' . $server_ip . PHP_EOL, FILE_APPEND | LOCK_EX);

$key = 2;
foreach ($ips as $ip) {
    if ($ip == $server_ip) {

        continue;
    }
    $str = "a$key.$domain " . $ip . PHP_EOL;
    file_put_contents($file, $str, FILE_APPEND | LOCK_EX);
    $key++;
}
echo 'Domains.php created!' . PHP_EOL;
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||' . PHP_EOL;
EOF