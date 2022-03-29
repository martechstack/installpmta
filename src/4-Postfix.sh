#!/usr/bin/env bash

echo "Установка и конфигурирование Postfix"
groupadd vmail -g 2222
useradd vmail -r -g 2222 -u 2222 -d /var/vmail -m -c "My Email user"
yum -y remove postfix
yum -y install postfix cronie opendkim

opendkim_config

primary_host=`cat domains.txt | cut -d " " -f 1 | head -n 1`

gpasswd -a postfix opendkim
gpasswd -a postfix vmail

cp /etc/postfix/master.cf{,.orig}
cat <<'EOF' >> /etc/postfix/master.cf
#
# Postfix master process configuration file.  For details on the format
# of the file, see the master(5) manual page (command: "man 5 master" or
# on-line: http://www.postfix.org/master.5.html).
#
# Do not forget to execute "postfix reload" after editing this file.
#
# ==========================================================================
# service type  private unpriv  chroot  wakeup  maxproc command + args
#               (yes)   (yes)   (no)    (never) (100)
# ==========================================================================
smtp      inet  n       -       n       -       -       smtpd
dovecot   unix  - n n - - pipe
  flags=DRhu user=vmail:vmail argv=/usr/libexec/dovecot/dovecot-lda -f ${sender} -d ${recipient}
#smtpd     pass  -       -       n       -       -       smtpd
#dnsblog   unix  -       -       n       -       0       dnsblog
#tlsproxy  unix  -       -       n       -       0       tlsproxy
#submission inet n       -       n       -       -       smtpd
#  -o syslog_name=postfix/submission
#  -o smtpd_tls_security_level=encrypt
#  -o smtpd_sasl_auth_enable=yes
#  -o smtpd_tls_auth_only=yes
#  -o smtpd_reject_unlisted_recipient=no
#  -o smtpd_client_restrictions=$mua_client_restrictions
#  -o smtpd_helo_restrictions=$mua_helo_restrictions
#  -o smtpd_sender_restrictions=$mua_sender_restrictions
#  -o smtpd_recipient_restrictions=
#  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
#  -o milter_macro_daemon_name=ORIGINATING
#smtps     inet  n       -       n       -       -       smtpd
#  -o syslog_name=postfix/smtps
#  -o smtpd_tls_wrappermode=yes
#  -o smtpd_sasl_auth_enable=yes
#  -o smtpd_reject_unlisted_recipient=no
#  -o smtpd_client_restrictions=$mua_client_restrictions
#  -o smtpd_helo_restrictions=$mua_helo_restrictions
#  -o smtpd_sender_restrictions=$mua_sender_restrictions
#  -o smtpd_recipient_restrictions=
#  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
#  -o milter_macro_daemon_name=ORIGINATING
pickup    unix  n       -       n       60      1       pickup
cleanup   unix  n       -       n       -       0       cleanup
qmgr      unix  n       -       n       300     1       qmgr
tlsmgr    unix  -       -       n       1000?   1       tlsmgr
rewrite   unix  -       -       n       -       -       trivial-rewrite
bounce    unix  -       -       n       -       0       bounce
defer     unix  -       -       n       -       0       bounce
trace     unix  -       -       n       -       0       bounce
verify    unix  -       -       n       -       1       verify
flush     unix  n       -       n       1000?   0       flush
proxymap  unix  -       -       n       -       -       proxymap
proxywrite unix -       -       n       -       1       proxymap
smtp      unix  -       -       n       -       -       smtp
relay     unix  -       -       n       -       -       smtp
        -o syslog_name=postfix/$service_name
#       -o smtp_helo_timeout=5 -o smtp_connect_timeout=5
showq     unix  n       -       n       -       -       showq
error     unix  -       -       n       -       -       error
retry     unix  -       -       n       -       -       error
discard   unix  -       -       n       -       -       discard
local     unix  -       n       n       -       -       local
virtual   unix  -       n       n       -       -       virtual
lmtp      unix  -       -       n       -       -       lmtp
anvil     unix  -       -       n       -       1       anvil
scache    unix  -       -       n       -       1       scache
submission inet n       -       n       -       -       smtpd
EOF

cp /etc/postfix/main.cf{,.orig}
echo "myhostname = mail.${primary_host} " > /etc/postfix/main.cf
cat <<'EOF' >> /etc/postfix/main.cf
queue_directory = /var/spool/postfix
command_directory = /usr/sbin
daemon_directory = /usr/libexec/postfix
data_directory = /var/lib/postfix
mail_owner = postfix
unknown_local_recipient_reject_code = 550
alias_maps = hash:/etc/postfix/aliases
alias_database = $alias_maps

inet_interfaces = all
inet_protocols = ipv4
mydestination =

debug_peer_level = 2
debugger_command =
         PATH=/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin
         ddd $daemon_directory/$process_name $process_id & sleep 5

sendmail_path = /usr/sbin/sendmail.postfix
newaliases_path = /usr/bin/newaliases.postfix
mailq_path = /usr/bin/mailq.postfix
setgid_group = postdrop
html_directory = no
manpage_directory = /usr/share/man
#sample_directory = /usr/share/doc/postfix-2.6.6/samples
#readme_directory = /usr/share/doc/postfix-2.6.6/README_FILES

relay_domains = *
virtual_alias_maps=hash:/etc/postfix/vmail_aliases
virtual_mailbox_domains=hash:/etc/postfix/vmail_domains
virtual_mailbox_maps=hash:/etc/postfix/vmail_mailbox

virtual_mailbox_base = /var/vmail
virtual_minimum_uid = 2222
virtual_transport = dovecot
virtual_uid_maps = static:2222
virtual_gid_maps = static:2222

# Milter configuration
milter_default_action = accept
milter_protocol = 6
smtpd_milters = inet:127.0.0.1:8891
non_smtpd_milters = $smtpd_milters

smtpd_sasl_auth_enable = yes
smtpd_sasl_type = dovecot
smtpd_sasl_path = /var/run/dovecot/auth-client
smtpd_sasl_security_options = noanonymous
smtpd_sasl_tls_security_options = $smtpd_sasl_security_options
smtpd_sasl_local_domain = $mydomain
broken_sasl_auth_clients = yes
smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination
smtpd_relay_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination
EOF
postconf -e dovecot_destination_recipient_limit=1
touch /etc/postfix/vmail_domains

while read line
do
IFS=' '
read -ra dom <<< "$line"
echo "${dom[0]}" >> /etc/postfix/vmail_domains
done < /root/domains.txt


touch /etc/postfix/vmail_mailbox
touch /etc/postfix/vmail_aliases

rm -f /tmp/vline
rm -f /tmp/vm
while read line
do
echo $line > /tmp/vline
echo "`cat /tmp/vline | awk '{print $1}'`                       OK">> /tmp/vm
done < /root/domains.txt
cat /tmp/vm > /etc/postfix/vmail_domains

rm -f /tmp/vline
rm -f /tmp/vm

postmap /etc/postfix/vmail_domains
postmap /etc/postfix/vmail_mailbox
postmap /etc/postfix/vmail_aliases
touch /etc/postfix/aliases
echo "submission inet n       -       n       -       -       smtpd" >> /etc/postfix/master.cf
echo " " >> /etc/postfix/master.cf

cat /dev/null > /usr/lib/systemd/system/postfix.service

cat <<'EOF'>> /usr/lib/systemd/system/postfix.service
[Unit]
Description=Postfix Mail Transport Agent
After=syslog.target network.target

[Service]
Type=forking
PIDFile=/var/spool/postfix/pid/master.pid
EnvironmentFile=-/etc/sysconfig/network
PrivateTmp=true
CapabilityBoundingSet=~ CAP_NET_ADMIN CAP_SYS_ADMIN CAP_SYS_BOOT CAP_SYS_MODULE
ProtectSystem=true
PrivateDevices=true
ExecStartPre=-/usr/libexec/postfix/aliasesdb
ExecStartPre=-/usr/libexec/postfix/chroot-update
ExecStart=/usr/sbin/postfix start
ExecReload=/usr/sbin/postfix reload
ExecStop=/usr/sbin/postfix stop

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable postfix && systemctl restart postfix
echo "Postfix успешно установлен"
echo ""
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||';
echo "ЭТАП 4 ЗАВЕРШЕН"
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||';