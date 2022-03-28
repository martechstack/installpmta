#!/usr/bin/env bash
sed -i 's/#Port 22/Port 1122/g' /etc/ssh/sshd_config
sudo systemctl restart sshd.service
echo 'Port changed!'