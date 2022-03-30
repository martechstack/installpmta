#!/usr/bin/env bash
cat <<'EOF' >>$HOME/set_domains.php
<?php
//todo need to configure:
$domain = '';
$server_id = '';
$server_ip = '';
$server_pass = '';
$api_key = '';

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
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\n';;
echo 'Domains.php created!';
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\n';;
EOF