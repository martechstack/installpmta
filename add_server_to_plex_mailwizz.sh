#!/usr/bin/env bash

config='config.json'
SERVER_IP=$(jq -r '.server_ip' "$config")
SERVER_NAME=$(jq -r '.server_name' "$config")
SERVER_PASS=$(jq -r '.server_pass' "$config")
DOMAIN=$(jq -r '.domain' "$config")

PLEX_USER=$(jq -r '.plex_user' "$config")
PLEX_PASS=$(jq -r '.plex_pass' "$config")
PLEX_DBNAME=$(jq -r '.plex_db' "$config")

MAILWIZZ_USER=$(jq -r '.mailwizz_user' "$config")
MAILWIZZ_PASS=$(jq -r '.mailwizz_pass' "$config")
MAILWIZZ_DBNAME=$(jq -r '.mailwizz_db' "$config")

# Add server to plex
echo "INSERT INTO plexmail.servers
(user_id, server_name, type, ip, login, password, pmt_password, number_pmta_port, pmta_port_panel, ip_panel_access, domen_name, emails) VALUES
(12, '$SERVER_NAME', 'sub', '$SERVER_IP', 'root', '$SERVER_PASS', '$SERVER_PASS', 2525, 1000, '94.158.179.114', '$DOMAIN', 'info@')" | mysql -u $PLEX_USER -p $PLEX_PASS $PLEX_DBNAME

# Add server to mailwizz
echo "INSERT INTO mailwizz.mw_delivery_server
(`server_id`, customer_id, bounce_server_id, tracking_domain_id, type, name, hostname, username, password, port, protocol, timeout, from_email, from_name, reply_to_email, probability, hourly_quota, daily_quota, monthly_quota, pause_after_send, meta_data, confirmation_key, locked, use_for, signing_enabled, force_from, force_reply_to, force_sender, must_confirm_delivery, max_connection_messages, status, date_added, `last_updated`) VALUES
(NULL, NULL, NULL, NULL, 'smtp-pmta', '$SERVER_NAME', '$SERVER_IP', 'pmtauser', '$SERVER_PASS', 2525, '', 30, 'twoandtwo4@gmail.com', 'Info', 'twoandtwo4@gmail.com', 100, 0, 0, 0, 0, 0x613A313A7B733A31383A226164646974696F6E616C5F68656164657273223B613A303A7B7D7D, NULL, 'no', 'all', 'yes', 'always', 'never', 'no', 'no', 1, 'active', '2022-03-08 22:12:18', '2022-03-22 17:00:43')" | mysql -u $MAILWIZZ_USER -p $MAILWIZZ_PASS $MAILWIZZ_DBNAME

curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/add_plex_ssh2_rule.sh | bash