#!/usr/bin/env bash

#yum install epel-release -y
#yum install jq -y
#config='config.json'
#DOMAIN=$(jq -r '.server_ip' "$config")

cat <<'EOF' >$HOME/set_virtualhost.php
<?php

$config = json_decode(file_get_contents('config.json'));
$domain = $config->domain;
$path_to_file = "/etc/pmta/virtualhost.txt";
$pattern1 = '/\<domain \*\>\n\s.*\<\/domain\>/i';
$pattern2 = '/\<domain \*\>\n\s.*\n\s.*\n\s.*\<\/domain\>/i';
$replacement1 = "<domain *>
    </domain>
    <domain $tmobile>
        max-msg-rate 1/s
    </domain>
    <domain $verizon>
        max-msg-rate 1/s
    </domain>
    <domain $att>
        max-msg-rate 1/s
    </domain>';
    $replacement2 = '<domain *>
        dkim-sign yes
        dkim-identity @$domain
    </domain>
    <domain $tmobile>
        max-msg-rate 1/s
    </domain>
    <domain $verizon>
        max-msg-rate 1/s
    </domain>
    <domain $att>
        max-msg-rate 1/s
    </domain>";
$content = file_get_contents($path_to_file);
$content = preg_replace($pattern1, $replacement1, $content);
$content = preg_replace($pattern2, $replacement2, $content);
file_put_contents($path_to_file, $content);
EOF

php $HOME/set_virtualhost.php
rm -rf $HOME/set_virtualhost.php

echo '/etc/pmta/virtualhost.txt has set!';
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||';echo '';
echo '';

