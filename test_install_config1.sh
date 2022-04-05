#!/usr/bin/env bash

cat <<'EOF' >$HOME/config.json
{
  "domain": "",
  "server_id": "",
  "server_ip": "",
  "server_pass": ""
  "api_key": ""
}
EOF

nano $HOME/config.json;