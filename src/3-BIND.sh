#!/usr/bin/env bash

echo "Установка Bind (named) DNS"
yum -y install bind bind-utils >/dev/null 2>/dev/null
mv /etc/named.conf /etc/named.conf.orig
touch /etc/named.conf
cat << 'EOF' > /etc/named.conf
options {
#       listen-on port 53 { 127.0.0.1; };
#        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        allow-query     { any; };
        allow-transfer  { localhost; };
        recursion no;
        dnssec-enable yes;
        dnssec-validation yes;

        /* Path to ISC DLV key */
        bindkeys-file "/etc/named.iscdlv.key";

        managed-keys-directory "/var/named/dynamic";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

EOF

rm -f /tmp/vline >/dev/null 2>/dev/null
rm -f /tmp/vm >/dev/null 2>/dev/null

echo "Генерация dkim"
openssl genrsa -out dkim.key 1024
openssl rsa -pubout -in dkim.key -out dkim.public
dkim=`cat dkim.public | sed '/^-/d' | awk '{printf "%s", $1}'`
cp dkim.key /etc/
chmod 0444 /etc/dkim.key


while read line
do
IFS=' '
read -ra domain <<< "$line"
echo "zone \"${domain[0]}\" IN {" >> /tmp/vm
echo "type master;" >> /tmp/vm
echo "file \"${domain[0]}.zone\";" >> /tmp/vm
echo "allow-update { none; };" >> /tmp/vm
echo "};" >> /tmp/vm
echo " " >> /tmp/vm
done < /root/domains.txt

head -n 2 /root/domains.txt

cat /tmp/vm >> /etc/named.conf

rm -f /tmp/vline >/dev/null 2>/dev/null
rm -f /tmp/vm >/dev/null 2>/dev/null
serial=`date +%Y%m%d00`

while read line
do
IFS=' '
read -ra domain <<< "$line"
# generate dkim
touch /var/named/${domain[0]}.zone
echo "\$ORIGIN ." > /var/named/${domain[0]}.zone
echo "\$TTL 86400" >> /var/named/${domain[0]}.zone
echo "${domain[0]}         IN      SOA             ns1.${domain[0]}.        it.${domain[0]}. (" >> /var/named/${domain[0]}.zone
echo "                                  $serial ; serial" >> /var/named/${domain[0]}.zone
echo "                                  300           ; refresh after 6 hours" >> /var/named/${domain[0]}.zone
echo "                                  600            ; retry after 1 hour" >> /var/named/${domain[0]}.zone
echo "                                  4800          ; expire after 1 week" >> /var/named/${domain[0]}.zone
echo "                                  86400 )         ; minimum TTL of 1 day" >> /var/named/${domain[0]}.zone
echo "" >> /var/named/${domain[0]}.zone
echo "                  IN      NS              ns1.${domain[0]}." >> /var/named/${domain[0]}.zone
echo "                  IN      NS              ns2.${domain[0]}." >> /var/named/${domain[0]}.zone
echo "" >> /var/named/${domain[0]}.zone
echo "                  IN      MX              10      mail.${domain[0]}." >> /var/named/${domain[0]}.zone
echo "                  IN      MX              20      mail.${domain[0]}." >> /var/named/${domain[0]}.zone


#add Nameservers
x=1
while read ips
do
IFS=' '
read -ra ipc <<< "$ips"
echo "ns${x}.${domain[0]}.                      IN      A               ${ipc[1]}" >> /var/named/${domain[0]}.zone
((x=x+1))
# two first lines and exit
if [[ "$x" == '3' ]]; then
break
fi
done < /root/domains.txt

echo "${domain[0]}.                      IN      A            ${domain[1]}   " >> /var/named/${domain[0]}.zone
echo "www.${domain[0]}.          IN      A               ${domain[1]}" >> /var/named/${domain[0]}.zone
echo "smtp.${domain[0]}.         IN      A               ${domain[1]}" >> /var/named/${domain[0]}.zone
echo "pop.${domain[0]}.          IN      A               ${domain[1]}" >> /var/named/${domain[0]}.zone
echo "imap.${domain[0]}.         IN      A               ${domain[1]}" >> /var/named/${domain[0]}.zone
echo "mail.${domain[0]}.         IN      A               ${domain[1]}" >> /var/named/${domain[0]}.zone
echo "ftp.${domain[0]}.          IN      A               ${domain[1]}" >> /var/named/${domain[0]}.zone

spfip=""
while read allips
do
IFS=' '
read -ra ipaddress <<< "$allips"
spfip+="ip4:"${ipaddress[1]}" "
done < /root/domains.txt

echo "${domain[0]}.                      IN      TXT             \"v=spf1 $spfip a mx ~all\"" >> /var/named/${domain[0]}.zone

echo "dkim5._domainkey.${domain[0]}.              IN      TXT             \"v=DKIM1; k=rsa; p=$dkim\"" >> /var/named/${domain[0]}.zone
echo "${domain[0]}.                      IN      TXT            \" mailru-verification: test\"" >> /var/named/${domain[0]}.zone
echo "_adsp._domainkey.${domain[0]}.             IN      TXT            \"dkim=all\"" >> /var/named/${domain[0]}.zone
echo "_dmarc.${domain[0]}.               IN      TXT             \"v=DMARC1; p=reject; adkim=s; aspf=s;\"" >> /var/named/${domain[0]}.zone

done < /root/domains.txt

echo "Bind DNS install successful"

systemctl enable named && systemctl restart named

echo ""
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||';echo '';;
echo "ЭТАП 3 ЗАВЕРШЕН"
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||';echo '';;