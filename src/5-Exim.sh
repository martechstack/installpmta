#!/usr/bin/env bash

echo "Установка и конфигурирование Exim"
groupadd vmail -g 2222
useradd vmail -r -g 2222 -u 2222 -d /var/vmail -m -c "My Email user"
yum -y install epel-release
yum -y remove exim
yum -y install exim
cp /etc/exim/exim.conf{,.orig}

rm -f /etc/exim/domain_dkim
rm -f /etc/exim/local_domains
touch /etc/exim/relay_hosts
touch /etc/exim/aliases
touch /etc/exim/filter
while read line
do
IFS=' '
read -ra dom <<< "$line"
echo "${dom[0]}: selector=dkim5 strict=true canon=relaxed key=/etc/dkim.key" >> /etc/exim/domain_dkim
echo " " >> /etc/exim/domain_dkim
echo "${dom[0]}" >> /etc/exim/local_domains
done < /root/domains.txt


primary_host=`cat domains.txt | cut -d " " -f 1 | head -n 1`


touch /etc/exim/exim.conf
cat <<'EOF' > /etc/exim/exim.conf

DKIM_DOMAIN = ${lookup{$sender_address_domain}lsearch*@{/etc/exim/domain_dkim}{$sender_address_domain}{}}
#DKIM_PRIVATE_KEY = ${extract{key}{${lookup{$sender_address_domain}lsearch*@{/etc/exim/domain_dkim}}}{$value}{}}
DKIM_PRIVATE_KEY = /etc/dkim.key
DKIM_SELECTOR = ${extract{selector}{${lookup{$sender_address_domain}lsearch*@{/etc/exim/domain_dkim}}}{$value}{}}
DKIM_CANON = ${extract{canon}{${lookup{$sender_address_domain}lsearch*@{/etc/exim/domain_dkim}}}{$value}{relaxed}}
DKIM_STRICT = ${extract{strict}{${lookup{$sender_address_domain}lsearch*@{/etc/exim/domain_dkim}}}{$value}{false}}
EOF

echo "primary_hostname = mail.${primary_host}" >> /etc/exim/exim.conf

cat <<'EOF' >> /etc/exim/exim.conf
system_filter = /etc/exim/filter

# Список доменов нашей почтовой системы
domainlist local_domains = /etc/exim/local_domains

# Список доменов, для которых наша почтовая система является резервной
domainlist relay_domains = /etc/exim/relay_domains

# Список узлов, почту от которых будем принимать без проверок
hostlist relay_from_hosts =

# Правила для проверок
acl_not_smtp = acl_check_not_smtp
acl_smtp_rcpt = acl_check_rcpt

# Отключаем IPv6, слушаем порты 25 и 587
disable_ipv6
daemon_smtp_ports = 2025 : 2027
EOF

echo "qualify_domain = ${primary_host}" >> /etc/exim/exim.conf

echo "qualify_recipient = ${primary_host}" >> /etc/exim/exim.conf

echo "tls_certificate = /etc/letsencrypt/live/mail.${primary_host}/fullchain.pem" >> /etc/exim/exim.conf
echo "tls_privatekey = /etc/letsencrypt/live/mail.${primary_host}/privkey.pem" >> /etc/exim/exim.conf
tls_on_connect_ports=2027

cat <<'EOF' >> /etc/exim/exim.conf
tls_advertise_hosts = *

# Пользователь от которого работает exim
exim_user = vmail

# группа в кторой работает exim
exim_group = vmail

# Exim никогда не должен запускать процессы от имени пользователя root
never_users = root

# Проверять прямую и обратную записи узла отправителя по DNS
host_lookup = *

# Отключаем проверку пользователей узла отправителя по протоколу ident
rfc1413_hosts = *
rfc1413_query_timeout = 0s

# Только эти узлы могут не указывать домен отправителя или получателя
sender_unqualified_hosts = +relay_from_hosts
recipient_unqualified_hosts = +relay_from_hosts

# Лимит размера сообщения, 30 мегабайт
message_size_limit = 30M

# Запрещаем использовать знак % для явной маршрутизации почты
percent_hack_domains =

# Настройки обработки ошибок доставки, используются значения по умолчанию
ignore_bounce_errors_after = 2d
timeout_frozen_after = 7d

begin acl

  # Проверки для локальных отправителей
  acl_check_not_smtp:
     accept

  # Проверки на этапе RCPT
  acl_check_rcpt:
    accept hosts = :

    # Отклоняем неправильные адреса почтовых ящиков
    deny message = Restricted characters in address
         domains = +local_domains
         local_parts = ^[.] : ^.*[@%!/|]

    # Отклоняем неправильные адреса почтовых ящиков
    deny message = Restricted characters in address
         domains = !+local_domains
         local_parts = ^[./|] : ^.*[@%!] : ^.*/\\.\\./

    # В локальные ящики postmaster и abuse принимает почту всегда

    accept local_parts = postmaster : abuse
           domains = +local_domains

    # Проверяем существование домена отправителя
    require verify = sender

    # Принимаем почту от доверенных узлов, попутно исправляя заголовки письма
    accept hosts = +relay_from_hosts
           control = submission

    # Принимаем почту от аутентифицированных узлов, попутно исправляя заголовки письма
    accept authenticated = *
           control = submission/domain=

    # Для не доверенных и не аутентифицированных требуется, чтобы получатель был в домене,
    # ящик которого находится у cнас или для которого мы являемся резервным почтовым сервером
    require message = Relay not permitted
            domains = +local_domains : +relay_domains

    # Если домен правильный, то проверяем получателя
    require verify = recipient

    accept

begin routers

  # Поиск транспорта для удалённых получателей
  dnslookup:
    driver = dnslookup
    domains = ! +local_domains
    transport = remote_smtp
    ignore_target_hosts = 0.0.0.0 : 127.0.0.0/8
    no_more

  # Пересылки для локальных получателей из файла /etc/aliases
  system_aliases:
    driver = redirect
    allow_fail
    allow_defer
EOF

echo "domains = ${primary_host}" >> /etc/exim/exim.conf

cat << 'EOF' >> /etc/exim/exim.conf
    data = ${lookup{$local_part}lsearch{/etc/aliases}}

  # Пересылки для получателей в разных доменах
  aliases:
    driver = redirect
    allow_fail
    allow_defer
    data = ${lookup{$local_part@$domain}lsearch{/etc/exim/aliases}}

  # Получение почты на локальный ящик
  mailbox:
    driver = accept
    condition = ${lookup{$local_part@$domain}lsearch{/etc/dovecot/passwd}{yes}{no}}
    user = dovecot
    transport = dovecot_virtual_delivery
    cannot_route_message = Unknown user

begin transports

  # Транспорт для удалённых получателей
  remote_smtp:
    driver = smtp
    dkim_domain           = DKIM_DOMAIN
    dkim_selector         = dkim5
    dkim_private_key      = DKIM_PRIVATE_KEY

  # Транспорт для локальных получателей из Dovecot
  dovecot_virtual_delivery:
    driver = pipe
    command = /usr/lib/dovecot/dovecot-lda -d $local_part@$domain -f $sender_address
    message_prefix =
    message_suffix =
    delivery_date_add
    envelope_to_add
    return_path_add
    log_output
    user = vmail
    temp_errors = 64 : 69 : 70: 71 : 72 : 73 : 74 : 75 : 78

  begin retry

  *   *   F,2h,15m; G,16h,1h,1.5; F,4d,6h

  begin rewrite

begin authenticators

  # Использование LOGIN-аутентификации из Dovecot
  dovecot_login:
    driver = dovecot
    public_name = LOGIN
    server_socket = /var/run/dovecot/auth-client
    server_set_id = $auth1

  # Использование PLAIN-аутентификации из Dovecot
  dovecot_plain:
    driver = dovecot
    public_name = PLAIN
    server_socket = /var/run/dovecot/auth-client
    server_set_id = $auth1

EOF
chown -R vmail:vmail /var/log/exim
chown -R vmail:vmail /var/spool/exim
chown -R vmail:vmail /etc/exim/aliases
chown -R vmail:vmail /etc/exim/relay_hosts
chown -R vmail:vmail /etc/exim/local_domains

cat /dev/null > /usr/lib/systemd/system/exim.service

cat << 'EOF' >> /usr/lib/systemd/system/exim.service
[Unit]
Description=Exim Mail Transport Agent
After=network.target

[Service]
PrivateTmp=true
Environment=QUEUE=1h
EnvironmentFile=-/etc/sysconfig/exim
ExecStartPre=-/usr/libexec/exim-gen-cert
ExecStart=/usr/sbin/exim -bd -q${QUEUE}

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable exim && systemctl restart exim
echo "Exim успешно установлен"
echo ""
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||';echo '';;
echo "ЭТАП 5 ЗАВЕРШЕН"
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||';echo '';;