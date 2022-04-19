#!/usr/bin/env bash

cat <<'EOF' >$HOME/config.json




#{
#  "domain": "",
#  "server_id": "",
#  "server_ip": "",
#  "server_pass": "",
#  "api_key": "",
#  "plex_user": "",
#  "plex_pass": "",
#  "plex_db": ""
#}
EOF

echo 'Now input: nano config.json'
echo 'After that run install: curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/install_server.sh | bash'