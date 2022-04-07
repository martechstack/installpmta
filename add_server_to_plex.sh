#!/usr/bin/env bash

config='config.json'
SERVER_IP=$(jq -r '.server_ip' "$config")
SERVER_PASS=$(jq -r '.server_pass' "$config")
DOMAIN=$(jq -r '.domain' "$config")
DOMAIN=$(jq -r '.plex_user' "$config")
DOMAIN=$(jq -r '.plex_pass' "$config")
DOMAIN=$(jq -r '.plex_db' "$config")

# Add server to plex
echo "INSERT INTO plexmail.servers
(user_id, server_name, type, ip, login, password, pmt_password, number_pmta_port, pmta_port_panel, ip_panel_access, domen_name, emails) VALUES
(12, '$SERVER_IP', 'sub', '$SERVER_IP', 'root', '$SERVER_PASS', '$SERVER_PASS', 2525, 1000, '94.158.179.114', '$DOMAIN', 'info@')" | mysql -uplexmail -p4PQ0fh74d plexmail

curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/add_plex_ssh2_rule.sh | bash