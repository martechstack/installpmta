
cat <<'EOF' >$HOME/set_virtualhost.php
<?php

$path_to_file = "/etc/pmta/virtualhost.txt";
$pattern = '/\<domain \*\>\n\s.*\<\/domain\>/i';
$replacement = '<domain $tmobile>
        max-msg-rate 1/s
    </domain>
    <domain $verizon>
        max-msg-rate 1/s
    </domain>
    <domain $att>
        max-msg-rate 1/s
    </domain>';
$content = file_get_contents($path_to_file);

$content = preg_replace($pattern, $replacement, $content);

file_put_contents($path_to_file, $content);
EOF

php $HOME/set_virtualhost.php




