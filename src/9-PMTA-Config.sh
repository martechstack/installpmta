#!/usr/bin/env bash

echo "Идет создание конфигурация PMTA..."
mkdir /etc/pmta
touch /etc/pmta/virtualhost.txt
mailpass=`cat /root/mailpass.txt`
cat << 'EOF' > /etc/pmta/virtualhost.txt
############################################################################
# BEGIN: USERS/VIRTUAL-MTA / VIRTUAL-MTA-POOL / VIRTUAL-PMTA-PATTERN
############################################################################

<smtp-user pmtauser>
EOF
echo "        password $mailpass" >> /etc/pmta/virtualhost.txt
cat << 'EOF' >> /etc/pmta/virtualhost.txt
        source {pmta-auth}
</smtp-user>
<source {pmta-auth}>
        smtp-service yes
        always-allow-relaying yes
        require-auth true
        process-x-virtual-mta yes
        default-virtual-mta pmta-pool
        remove-received-headers true
        add-received-header false
        hide-message-source true
        #pattern-list pmta-pattern
        process-x-job false
</source>
<smtp-user pmta-pattern>
EOF
echo "        password $mailpass" >> /etc/pmta/virtualhost.txt
cat << 'EOF' >> /etc/pmta/virtualhost.txt
        source {pmta-pattern-auth}
</smtp-user>

<source {pmta-pattern-auth}>
        smtp-service yes
        always-allow-relaying yes
        require-auth true
        process-x-virtual-mta yes
        #default-virtual-mta pmta-pool
        remove-received-headers true
        add-received-header false
        hide-message-source true
        pattern-list pmta-pattern
        process-x-job false
</source>

########################################################################################
### START BLOK - 1 #####################################################################
########################################################################################

<virtual-mta-pool pmta-pool>
EOF
rm /tmp/vh >/dev/null 2>/dev/null
rm /tmp/vline >/dev/null 2>/dev/null
rm /tmp/subdomain >/dev/null 2>/dev/null
rm /tmp/sdline >/dev/null 2>/dev/null
rm /tmp/sbdone >/dev/null 2>/dev/null
while read line
do
echo $line > /tmp/vline
cat /root/domains.txt | grep `cat /tmp/vline | awk '{print $1}'` > /tmp/subdomain
if [ "`cat /tmp/subdomain | wc -l`" -ge "2" ]
then
    sed 1d < /tmp/subdomain > /tmp/sbdone
    while read line
    do
    echo $line > /tmp/sdline
    echo "virtual-mta `cat /tmp/sdline | awk '{print $1}'`-vmta" >> /tmp/vh
    done <  /tmp/sbdone
else
sleep 1
#echo "virtual-mta `cat /tmp/vline | awk '{print $1}'`-vmta">> /tmp/vh
fi
sleep 1
done < /root/domains.txt
cat /tmp/vh >> /etc/pmta/virtualhost.txt
cat << 'EOF' >> /etc/pmta/virtualhost.txt
</virtual-mta-pool>

### END BLOK - 1 #######################################################################

########################################################################################
### START BLOK - 2 #####################################################################
########################################################################################

<pattern-list pmta-pattern>
EOF
rm /tmp/vh >/dev/null 2>/dev/null
rm /tmp/vline >/dev/null 2>/dev/null
rm /tmp/subdomain >/dev/null 2>/dev/null
rm /tmp/sdline >/dev/null 2>/dev/null
rm /tmp/sbdone >/dev/null 2>/dev/null
while read line
do
echo $line > /tmp/vline
cat /root/domains.txt | grep `cat /tmp/vline | awk '{print $1}'` > /tmp/subdomain
if [ "`cat /tmp/subdomain | wc -l`" -ge "2" ]
then
    sed '2, 9999d' < /tmp/subdomain > /tmp/sbdone
    while read line
    do
    echo $line > /tmp/sdline
    echo "mail-from /@`cat /tmp/sdline | awk '{print $1}'`/ virtual-mta=pmta-pool">> /tmp/vh
    done <  /tmp/sbdone
else
sleep 1
#echo "mail-from /@`cat /tmp/vline | awk '{print $1}'`/ virtual-mta=`cat /tmp/vline | awk '{print $1}'`-vmta">> /tmp/vh
fi
sleep 1
done < /root/domains.txt
cat /tmp/vh >> /etc/pmta/virtualhost.txt
cat << 'EOF' >> /etc/pmta/virtualhost.txt
</pattern-list>

### END BLOK - 2 #######################################################################

EOF

rm /tmp/vh >/dev/null 2>/dev/null
rm /tmp/vline >/dev/null 2>/dev/null
num=1
sed '2, 9999d' < /root/domains.txt > /tmp/maindomain
sed 1d < /root/domains.txt > /tmp/subdone
while read line
do
echo $line > /tmp/vline
echo "########################################################################################">> /tmp/vh
echo "### START DOMAIN - $num ###################################################################">> /tmp/vh
echo "########################################################################################">> /tmp/vh
echo " ">> /tmp/vh
echo "<smtp-user `cat /tmp/vline | awk '{print $1}'`-vmta>">> /tmp/vh
echo " password $mailpass">> /tmp/vh
echo "source {`cat /tmp/vline | awk '{print $1}'`-vmta-auth}">> /tmp/vh
echo "</smtp-user>">> /tmp/vh
echo " ">> /tmp/vh
echo "<source {`cat /tmp/vline | awk '{print $1}'`-vmta-auth}>">> /tmp/vh
echo " smtp-service yes">> /tmp/vh
echo " always-allow-relaying yes">> /tmp/vh
echo " require-auth true">> /tmp/vh
echo " process-x-virtual-mta yes">> /tmp/vh
echo " default-virtual-mta `cat /tmp/vline | awk '{print $1}'`-vmta">> /tmp/vh
echo " remove-received-headers true">> /tmp/vh
echo " add-received-header false">> /tmp/vh
echo " hide-message-source true">> /tmp/vh
echo " process-x-job false">> /tmp/vh
echo "</source>">> /tmp/vh
echo " ">> /tmp/vh
echo "<virtual-mta `cat /tmp/vline | awk '{print $1}'`-vmta>">> /tmp/vh
echo " ">> /tmp/vh
echo "auto-cold-virtual-mta `cat /tmp/vline | awk '{print $2}'` `cat /tmp/vline | awk '{print $1}'`">> /tmp/vh
echo "domain-key dkim5,`cat /tmp/vline | awk '{print $1}'`,/etc/dkim.key">> /tmp/vh
echo "max-smtp-out 850">> /tmp/vh
echo "    <domain *>">> /tmp/vh
echo "    </domain>">> /tmp/vh
echo "smtp-source-host `cat /tmp/vline | awk '{print $2}'` `cat /tmp/vline | awk '{print $1}'`">> /tmp/vh
echo "</virtual-mta>">> /tmp/vh
echo " ">> /tmp/vh
echo "### END DOMAIN - $num #####################################################################">> /tmp/vh
echo " ">> /tmp/vh
done < /tmp/maindomain
cat /tmp/vh >> /etc/pmta/virtualhost.txt
rm /tmp/vh >/dev/null 2>/dev/null
rm /tmp/vline >/dev/null 2>/dev/null
num=2
while read line
do
echo $line > /tmp/vline
echo "########################################################################################">> /tmp/vh
echo "### START DOMAIN - $num ###################################################################">> /tmp/vh
echo "########################################################################################">> /tmp/vh
echo " ">> /tmp/vh
echo "<smtp-user `cat /tmp/vline | awk '{print $1}'`-vmta>">> /tmp/vh
echo " password $mailpass">> /tmp/vh
echo "source {`cat /tmp/vline | awk '{print $1}'`-vmta-auth}">> /tmp/vh
echo "</smtp-user>">> /tmp/vh
echo " ">> /tmp/vh
echo "<source {`cat /tmp/vline | awk '{print $1}'`-vmta-auth}>">> /tmp/vh
echo " smtp-service yes">> /tmp/vh
echo " always-allow-relaying yes">> /tmp/vh
echo " require-auth true">> /tmp/vh
echo " process-x-virtual-mta yes">> /tmp/vh
echo " default-virtual-mta `cat /tmp/vline | awk '{print $1}'`-vmta">> /tmp/vh
echo " remove-received-headers true">> /tmp/vh
echo " add-received-header false">> /tmp/vh
echo " hide-message-source true">> /tmp/vh
echo " process-x-job false">> /tmp/vh
echo "</source>">> /tmp/vh
echo " ">> /tmp/vh
echo "<virtual-mta `cat /tmp/vline | awk '{print $1}'`-vmta>">> /tmp/vh
echo " ">> /tmp/vh
echo "auto-cold-virtual-mta `cat /tmp/vline | awk '{print $2}'` `cat /tmp/vline | awk '{print $1}'`">> /tmp/vh
echo "domain-key dkim5,`cat /tmp/maindomain | awk '{print $1}'`,/etc/dkim.key">> /tmp/vh
echo "max-smtp-out 850">> /tmp/vh
echo "    <domain *>">> /tmp/vh
echo "    dkim-sign yes">> /tmp/vh
echo "    dkim-identity @`cat /tmp/maindomain | awk '{print $1}'`">> /tmp/vh
echo "    </domain>">> /tmp/vh
echo "smtp-source-host `cat /tmp/vline | awk '{print $2}'` `cat /tmp/maindomain | awk '{print $1}'`">> /tmp/vh
echo "</virtual-mta>">> /tmp/vh
echo " ">> /tmp/vh
echo "### END DOMAIN - $num #####################################################################">> /tmp/vh
echo " ">> /tmp/vh
num=$(($num + 1))
done <  /tmp/subdone
cat /tmp/vh >> /etc/pmta/virtualhost.txt
echo "Конфигурация PMTA успешно создана"
echo ""
sleep 1
rm /tmp/vm >/dev/null 2>/dev/null
rm /tmp/vh >/dev/null 2>/dev/null
rm /tmp/vline >/dev/null 2>/dev/null
rm /tmp/vmp >/dev/null 2>/dev/null
rm $archname >/dev/null 2>/dev/null
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||';echo '';
echo "ЭТАП 9 ЗАВЕРШЕН"
echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||';echo '';
echo ""