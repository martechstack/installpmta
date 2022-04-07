#!/usr/bin/env bash

#yum install epel-release -y
#yum install jq -y
#config='config.json'
#PMTA_DOMAIN=$(jq -r '.domain' "$config")

cat <<'EOF' >$HOME/set_domains.php
<?php

$config = json_decode(file_get_contents('config.json'));

$domain = $config->domain;
$server_id = $config->server_id;
$server_ip = $config->server_ip;
$server_pass = $config->server_pass;
$api_key = $config->api_key;

//todo insert configs
$file = 'domains.txt';
$file_mailpass = 'mailpass.txt';
$data = [
    "action" => "get_instance_ips",
    "serviceid" => $server_id,
    "API" => $api_key,
];
$data_string = json_encode($data);

$ch = curl_init('http://clients.hostwinds.com/cloud/api.php');
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
curl_setopt($ch, CURLOPT_POSTFIELDS, $data_string);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Content-Length: ' . strlen($data_string)
]);

$result = curl_exec($ch);
$result = json_decode($result, true);
if (empty($result['success']['IP Addresses'])) {
    die('Array of IPs is empty...');
}
file_put_contents($file_mailpass, $server_pass);
file_put_contents($file, $domain . ' ' . $server_ip . PHP_EOL);
file_put_contents($file, 'a1.' .$domain . ' ' . $server_ip . PHP_EOL, FILE_APPEND | LOCK_EX);
$ips = $result['success']['IP Addresses'];

$key = 2;
foreach ($ips as $ip) {
    if ($ip['ip'] == $server_ip) {

        continue;
    }
    $str = "a$key.$domain " . $ip['ip'] . PHP_EOL;
    file_put_contents($file, $str, FILE_APPEND | LOCK_EX);
    $key++;
}
echo 'Domains.php created!' . PHP_EOL;
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||' . PHP_EOL;
EOF