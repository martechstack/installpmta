#!/usr/bin/env bash

echo "Установка и конфигурирование Dovecot"
yum -y install dovecot
cp /etc/dovecot/dovecot.conf{,.orig}
cat <<'EOF' > /etc/dovecot/dovecot.conf
listen = *
ssl = no
protocols = pop3 imap
disable_plaintext_auth = no
auth_mechanisms = plain login
mail_access_groups = vmail
default_login_user = vmail
first_valid_uid = 2222
first_valid_gid = 2222
#mail_location = maildir:~/Maildir
mail_location = maildir:/var/vmail/%d/%n

passdb {
    driver = passwd-file
    args = scheme=SHA1 /etc/dovecot/passwd
}
userdb {
    driver = static
    args = uid=2222 gid=2222 home=/var/vmail/%d/%n allow_all_users=yes
}
service auth {
    unix_listener auth-client {
        group = vmail
        mode = 0660
        user = vmail
    }
    user = root
}
service imap-login {
  process_min_avail = 1
  user = vmail
}
EOF
rm -f /etc/dovecot/passwd
touch /etc/dovecot/passwd
chown root: /etc/dovecot/passwd
chmod 600 /etc/dovecot/passwd
systemctl restart postfix
systemctl enable dovecot && systemctl restart dovecot
echo "Dovecot успешно установлен"
echo ""
sleep 1
echo ""
echo "Создаем почтовые ящики"
echo ""
p=`cat /root/mailpass.txt`
pass=`doveadm pw -p $p -s sha1 | cut -d '}' -f2`

rm -f /etc/dovecot/passwd
while read doma
do
IFS=' '
read -ra domain <<< "$doma"

while read line
do

echo "$line${domain[0]}:$pass" >> /etc/dovecot/passwd
echo "$line${domain[0]} ${domain[0]}/$line" >> /etc/postfix/vmail_mailbox
done < /root/mailbox.txt
done < /root/domains.txt
postmap /etc/postfix/vmail_mailbox
systemctl reload postfix
echo "Пользователи почты добавлены в систему"
echo ""
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\n';;
echo "ЭТАП 6 ЗАВЕРШЕН"
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\n';;