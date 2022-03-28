#!/usr/bin/env bash
#cat <<'EOF' >>/etc/pmta/config
cat <<'EOF' >>test_config.txt

#####################################################################################################################################
# Section 1: POTOKI
#####################################################################################################################################

total-max-smtp-in 1000
total-max-smtp-out 5000

#####################################################################################################################################
# Section 2: SOURCE
#####################################################################################################################################

<source 127.0.0.1>
always-allow-relaying yes   # allow feeding from 127.0.0.1
process-x-virtual-mta yes   # allow selection of a virtual MTA
max-message-size 0
smtp-service yes            # allow SMTP service
remove-received-headers true
add-received-header false
hide-message-source true
remove-header X-Priority
pattern-list sender
</source>

#####################################################################################################################################
# Section 3: MAIN SETTINGS / VIRTUAL-MTA-POOL
#####################################################################################################################################

smtp-listener 0/0:2525        # Port PMTA
http-mgmt-port 1000
http-access 127.0.0.1 monitor
http-access ::1 monitor
http-redirect-to-https false
run-as-root no

#####################################################################################################################################
# Section 3: BASE SETTINGS FOR LOCALHOST
#####################################################################################################################################

<source 0/0>
log-connections no
log-commands    no          # WARNING: verbose!
log-data        no          # WARNING: even more verbose!
allow-unencrypted-plain-auth yes
default-virtual-mta by-smtp-source-ip
process-x-virtual-mta yes
smtp-service yes
always-allow-api-submission yes
pattern-list pmta-pattern
</source>

include /etc/pmta/virtualhost.txt

#####################################################################################################################################
# Section 4: BOUNCE SETTINGS
#####################################################################################################################################

<bounce-category-patterns>
    /spam/ spam-related
    /junk mail/ spam-related
    /blacklist/ spam-related
    /blocked/ spam-related
    /\bU\.?C\.?E\.?\b/ spam-related
    /\bAdv(ertisements?)?\b/ spam-related
    /unsolicited/ spam-related
    /\b(open)?RBL\b/ spam-related
    /realtime blackhole/ spam-related
    /http:\/\/basic.wirehub.nl\/blackholes.html/ spam-related
    /\bvirus\b/ virus-related
    /message +content/ content-related
    /content +rejected/ content-related
    /quota/ quota-issues
    /limit exceeded/ quota-issues
    /mailbox +(is +)?full/ quota-issues
    /sender ((verify|verification) failed|could not be verified|address rejected|domain must exist)/ invalid-sender
    /unable to verify sender/ invalid-sender
    /requires valid sender domain/ invalid-sender
    /bad sender's system address/ invalid-sender
    /No MX for envelope sender domain/ invalid-sender
    /^[45]\.4\.4/ routing-errors
    /no mail hosts for domain/ invalid-sender
    /Your domain has no(t)? DNS\/MX entries/ invalid-sender
    /REQUESTED ACTION NOT TAKEN: DNS FAILURE/ invalid-sender
    /Domain of sender address/ invalid-sender
    /return MX does not exist/ invalid-sender
    /Invalid sender domain/ invalid-sender
    /Verification failed/ invalid-sender
    /\bstorage\b/ quota-issues
    /(user|mailbox|recipient|rcpt|local part|address|account|mail drop|ad(d?)ressee) (has|has been|is)? *(currently|temporarily +)?(disabled|expired|inactive|not activa
    ted)/ inactive-mailbox
    /(conta|usu.rio) inativ(a|o)/ inactive-mailbox
    /Too many (bad|invalid|unknown|illegal|unavailable) (user|mailbox|recipient|rcpt|local part|address|account|mail drop|ad(d?)ressee)/ other
    /(No such|bad|invalid|unknown|illegal|unavailable) (local +)?(user|mailbox|recipient|rcpt|local part|address|account|mail drop|ad(d?)ressee)/ bad-mailbox
    /(user|mailbox|recipient|rcpt|local part|address|account|mail drop|ad(d?)ressee) +(\S+@\S+ +)?(not (a +)?valid|not known|not here|not found|does not exist|bad|inval
    id|unknown|illegal|unavailable)/ bad-mailbox
    /\S+@\S+ +(is +)?(not (a +)?valid|not known|not here|not found|does not exist|bad|invalid|unknown|illegal|unavailable)/ bad-mailbox
    /no mailbox here by that name/ bad-mailbox
    /my badrcptto list/ bad-mailbox
    /not our customer/ bad-mailbox
    /no longer (valid|available)/ bad-mailbox
    /have a \S+ account/ bad-mailbox
    /\brelay(ing)?/ relaying-issues
    /domain (retired|bad|invalid|unknown|illegal|unavailable)/ bad-domain
    /domain no longer in use/ bad-domain
    /domain (\S+ +)?(is +)?obsolete/ bad-domain
    /denied/ policy-related
    /prohibit/ policy-related
    /refused/ policy-related
    /allowed/ policy-related
    /banned/ policy-related
    /policy/ policy-related
    /suspicious activity/ policy-related
    /bad sequence/ protocol-errors
    /syntax error/ protocol-errors
    /syntax error/ protocol-errors
    /\broute\b/ routing-errors
    /\bunroutable\b/ routing-errors
    /\bunrouteable\b/ routing-errors
    /Invalid 7bit DATA/ content-related
    /^2.\d+.\d+;/ success
    /^[45]\.1\.[1346];/ bad-mailbox
    /^[45]\.1\.2/ bad-domain
    /^[45]\.1\.[78];/ invalid-sender
    /^[45]\.2\.0;/ bad-mailbox
    /^[45]\.2\.1;/ inactive-mailbox
    /^[45]\.2\.2;/ quota-issues
    /^[45]\.3\.3;/ content-related
    /^[45]\.3\.5;/ bad-configuration
    /^[45]\.4\.1;/ no-answer-from-host
    /^[45]\.4\.2;/ bad-connection
    /^[45]\.4\.[36];/ routing-errors
    /^[45]\.4\.7;/ message-expired
    /^[45]\.5\.3;/ policy-related
    /^[45]\.5\.\d+;/ protocol-errors
    /^[45]\.6\.\d+;/ content-related
    /^[45]\.7\.[012];/ policy-related
    /^[45]\.7\.7;/ content-related
    // other # catch-all
</bounce-category-patterns>

<pattern-list sender>
    #        rcpt-to /^.*@gmail.com$/ virtual-mta=vmta-pool-v6
    #        rcpt-to /^.*@yandex.ru$/ virtual-mta=vmta-pool-v6
</pattern-list>

#####################################################################################################################################
# Section 5: DOMAIN SETTINGS
#####################################################################################################################################
#####################################################################################################################################
# VERIZON #
#####################################################################################################################################

# domains that resolve to VTEXT.COM
domain-macro verizon vtext.com

<domain $verizon>
    use-starttls no
    max-smtp-out 5                                                  # default be nice on concurrent connections
    max-msg-per-connection 1                                       # max 500 mails in one session
    max-rcpt-per-message 1
    max-errors-per-connection 10                                    # avoid 'too long without data command' error
    reuse-ssl-session no

    #max-msg-rate unlimited

    bounce-upon-no-mx yes                                           # proper mail domains should have mx
    assume-delivery-upon-data-termination-timeout yes               # avoid duplicate deliveries
    smtp-421-means-mx-unavailable yes
    smtp-553-means-invalid-mailbox yes
    bounce-upon-5xx-greeting true
    connect-timeout 1m
    smtp-greeting-timeout 5m
    data-send-timeout 5m
    retry-after 30m                                                 # typical greylisting period
    bounce-after 3d                                                 # default 4d12h

    smtp-pattern-list blocking-errors
    backoff-max-msg-rate 1/h                                        # send only regular tries during backoff (default unlimited)
    backoff-retry-after 10m,3h,6h,12h                                # retry at least every 20m (default 1h)
    backoff-to-normal-after-delivery yes                            # revert to normal asap (default no)
    backoff-to-normal-after 1h                                      # always revert to normal after 1h (default never)

    dk-sign yes
    dkim-sign yes
    deliver-local-dsn no
</domain>

#####################################################################################################################################
# ATT #
#####################################################################################################################################

# domains that resolve to txt.att.net
domain-macro att txt.att.net

<domain $att>
    use-starttls no
    max-smtp-out 5
    max-msg-per-connection 1
    max-rcpt-per-message 1
    max-errors-per-connection 10
    reuse-ssl-session no

    #max-msg-rate unlimited

    bounce-upon-no-mx yes
    assume-delivery-upon-data-termination-timeout yes               # avoid duplicate deliveries
    smtp-421-means-mx-unavailable yes
    smtp-553-means-invalid-mailbox yes
    bounce-upon-5xx-greeting true
    connect-timeout 1m
    smtp-greeting-timeout 5m
    data-send-timeout 5m
    retry-after 30m
    bounce-after 3d

    smtp-pattern-list blocking-errors
    backoff-max-msg-rate 1/h
    backoff-retry-after 1h,3h,6h,12h
    backoff-to-normal-after-delivery yes
    backoff-to-normal-after 1h

    dk-sign yes
    dkim-sign yes
    deliver-local-dsn no
</domain>



#####################################################################################################################################
# TMOBILE #
#####################################################################################################################################

# domains that resolve to TMOMAIL.NET
domain-macro tmobile tmomail.net

<domain $tmobile>
    use-starttls no
    max-smtp-out 5
    max-msg-per-connection 1
    max-rcpt-per-message 1
    max-errors-per-connection 10
    reuse-ssl-session no

    #max-msg-rate unlimited

    bounce-upon-no-mx yes
    assume-delivery-upon-data-termination-timeout yes               # avoid duplicate deliveries
    smtp-421-means-mx-unavailable yes
    smtp-553-means-invalid-mailbox yes
    bounce-upon-5xx-greeting true
    connect-timeout 1m
    smtp-greeting-timeout 5m
    data-send-timeout 5m
    retry-after 30m
    bounce-after 3d

    smtp-pattern-list blocking-errors
    backoff-max-msg-rate 1/h
    backoff-retry-after 1h,3h,6h,12h
    backoff-to-normal-after-delivery yes
    backoff-to-normal-after 1h

    dk-sign yes
    dkim-sign yes
    deliver-local-dsn no
</domain>

#####################################################################################################################################
# MAIL.RU #
#####################################################################################################################################

# domains that resolve to MAIL.RU
domain-macro mailru mail.ru,bk.ru,inbox.ru,list.ru,mail.ua,mail.kz

<domain $mailru>
    use-starttls no
    max-smtp-out 1                                                  # default be nice on concurrent connections
    max-msg-per-connection 1                                       # max 500 mails in one session
    max-rcpt-per-message 1
    max-errors-per-connection 10                                    # avoid 'too long without data command' error
    reuse-ssl-session no

    max-msg-rate 2/m

    bounce-upon-no-mx yes                                           # proper mail domains should have mx
    assume-delivery-upon-data-termination-timeout yes               # avoid duplicate deliveries
    smtp-421-means-mx-unavailable yes
    smtp-553-means-invalid-mailbox yes
    bounce-upon-5xx-greeting true
    connect-timeout 1m
    smtp-greeting-timeout 5m
    data-send-timeout 5m
    retry-after 30m                                                 # typical greylisting period
    bounce-after 3d                                                 # default 4d12h

    smtp-pattern-list blocking-errors
    backoff-max-msg-rate 1/h                                        # send only regular tries during backoff (default unlimited)
    backoff-retry-after 1h,3h,6h,12h                                # retry at least every 20m (default 1h)
    backoff-to-normal-after-delivery yes                            # revert to normal asap (default no)
    backoff-to-normal-after 1h                                      # always revert to normal after 1h (default never)

    dk-sign yes
    dkim-sign yes
    deliver-local-dsn no
</domain>

#####################################################################################################################################
# RAMBLER #
#####################################################################################################################################

# domains that resolve to RAMBLER
domain-macro rambler rambler.ru

<domain $rambler>
    use-starttls no
    max-smtp-out 1                                                  # default be nice on concurrent connections
    max-msg-per-connection 1                                       # max 500 mails in one session
    max-rcpt-per-message 1
    max-errors-per-connection 10                                    # avoid 'too long without data command' error
    reuse-ssl-session no

    max-msg-rate 2/m

    bounce-upon-no-mx yes                                           # proper mail domains should have mx
    assume-delivery-upon-data-termination-timeout yes               # avoid duplicate deliveries
    smtp-421-means-mx-unavailable yes
    smtp-553-means-invalid-mailbox yes
    bounce-upon-5xx-greeting true
    connect-timeout 1m
    smtp-greeting-timeout 5m
    data-send-timeout 5m
    retry-after 30m                                                 # typical greylisting period
    bounce-after 3d                                                 # default 4d12h

    smtp-pattern-list blocking-errors
    backoff-max-msg-rate 1/h                                        # send only regular tries during backoff (default unlimited)
    backoff-retry-after 1h,3h,6h,12h                                # retry at least every 20m (default 1h)
    backoff-to-normal-after-delivery yes                            # revert to normal asap (default no)
    backoff-to-normal-after 1h                                      # always revert to normal after 1h (default never)

    dk-sign yes
    dkim-sign yes
    deliver-local-dsn no
</domain>

#####################################################################################################################################
# UKR.NET #
#####################################################################################################################################

# domains that resolve to UKR.NET
domain-macro ukrnet ukr.net

<domain $ukrnet>
    use-starttls no
    max-smtp-out 1                                                  # default be nice on concurrent connections
    max-msg-per-connection 1                                       # max 500 mails in one session
    max-rcpt-per-message 1
    max-errors-per-connection 10                                    # avoid 'too long without data command' error
    reuse-ssl-session no

    max-msg-rate 2/m

    bounce-upon-no-mx yes                                           # proper mail domains should have mx
    assume-delivery-upon-data-termination-timeout yes               # avoid duplicate deliveries
    smtp-421-means-mx-unavailable yes
    smtp-553-means-invalid-mailbox yes
    bounce-upon-5xx-greeting true
    connect-timeout 1m
    smtp-greeting-timeout 5m
    data-send-timeout 5m
    retry-after 30m                                                 # typical greylisting period
    bounce-after 3d                                                 # default 4d12h

    smtp-pattern-list blocking-errors
    backoff-max-msg-rate 1/h                                        # send only regular tries during backoff (default unlimited)
    backoff-retry-after 1h,3h,6h,12h                                # retry at least every 20m (default 1h)
    backoff-to-normal-after-delivery yes                            # revert to normal asap (default no)
    backoff-to-normal-after 1h                                      # always revert to normal after 1h (default never)

    dk-sign yes
    dkim-sign yes
    deliver-local-dsn no
</domain>

#####################################################################################################################################
# HOTMAIL #
#####################################################################################################################################

domain-macro hotmail hotmail.fr,live.com,hotmail.co.uk,hotmail.it,windowslive.com,live.fr,hotmail.de,hotmail.es,live.co.uk,live.it,hotmail.co.jp,live.com.mx,live.nl,live.de,live.cn,live.ru,live.ca,live.com.ar,hotmail.co.th,live.com.au,live.jp,live.se,live.cl,live.com.pt, live.be, live.dk, hotmail.com.tr, livemail.tw, live.no, hotmail.se , hotmail.com.tw,live.co.kr,hotmail.co.nz,live.at,live.in,hotmail.gr,hotmail.be,live.hk,live.ie,msn.cn,hotmail.co.kr,hotmail.no,hotmail.ch,live.co.za,hotmail.com.hk,live.com.my,live.com.sg,hotmail.fi,hotmail.my, hotmail.co.id, hotmail.sg, hotmail.com.au, hotmail.co.za, hotmail.dk, hotmail.rs,live.com.ph, hotmail.ph, hotmail.com.vn, hotmail.cz, bobdickey.com, bodystructure.com, bramsonsco.com, brokerlosangeles.com, brturner.com, brundagerealty.com, buenavistaproperty.com, buhrfiend.com, buyersnetwork.com, calderonrealty.net, calpremium.com, camparealestate.com, capemaymorrows.com, carllacey.com, carlosandteam.com, carolinafallprotection.com, carolnorthcott.com, carrengineering.com, casasarizona.info, cbaininc.com, cbcsteele.com, cclfinancial.com, centre-pointe.com, chandlerscott.org, chattanoogarealestateco.com, childrensservicescenter.org, ckgtherealtor.com, classified-ads.com, cmchildcare.org, cnnpropertymanagement.com, colme.org, colonialrestaurant.com, columbusmetrohomes.com, communitycare707.com, commxx.com, compassroads.com, cpsweb.org, crawfordsprinklercompany.com, crgllc.com, cri-ri.com, crownwarehousing.com, ctvet.com, dallisketchum.com, danielconstruction.com, dannyks.com, davesmolizer.com, dineseptembers.com, djshomeexperts.com, dkschools1.org, doe.com, dorothyharmon.com, drmarkou.com, duanelpeterson.com, dubas.com, dysertconcrete.com, e3acquisitions.com, earnwithvern.net, easyrentalsnj.com, ecmontereybay.com, elia-inc.com, elpasorealestateconsultants.com, email.itt-tech.edu, email.msn.com, enviromedservices.com, eptexrealtor.org, equity1realty.com, erhartfire.org, eswinc.com, eurihea.com, evansrealestateinc.com, everreadyelectric.net, excelemp.com, fbcnn.org, fbcripley.com, filanninoandtiangco.com, finkelectric.com, fintzrealty.net, floressierra.com, forpages.com, fosterheatingandair.com, fourriversrealty.net, fuae.net, fullerisford.com, gallowayrealestateinc.com, ggelec.com, glenwoodgsca.com, godsgang1.net, graneted.com, granitecresthomes.com, greg41.com, gregrich.com, hanleyappraisals.com, hannamfg.com, haxtechnologies.com, heatingcoolingoutlet.com, hellevik.com, hellorick.com, hensenhomes.com, hicksre.com, hol.gr, holyspiritschool.net, homeelegance.com, homestratumgroup.com, hotmail.ca, hotmail.co.jp, hotmail.co.uk, hotmail.com, hotmail.com.au, hotmail.es, hotmail.fr, hotmail.it, ijango.com, ilreoagent.com, imaxrealtors.com, innovateconsulting.com, innsofamerica.com, interactionintl.org, invesmart.net, investcorprealestate.com, invictus63.com, irenthomes.net, ITMORTGAGE.COM, jacarisupply.com, jagodik.com, jamesbrooksco.com, jamisonrealtors.com, janegregory.com, janneyteam.com, jbwalkers.com, jdhomes.net, joshuaregroup.com, joyparadise.com, jrcollinsrealtor.com, kaucky.com, kbwappraisals.com, kdrsteel.com, keithscustomcarpentry.com, kfigeneralcontractor.com, kienerappraisal.com, kristimartinez.com, kristyhairston.com, lakesidesf.org, lamonicas.com, laurarosca.com, lauriegoode.com, lauriesmithbl.com, lcmeats.com, legentwprealty.com, leisurevillas.com, leopursley.com, lideramos.com, lindstrom.org, littlefieldrealtyco.com, live.ca, live.cn, live.co.uk, live.com, live.com.au, live.com.mx, live.de, live.fr, live.ie, live.jp, livingindoors.com, lorrainegrifo.com, lpfhomes.com, lrpm.net, luzamo.com, marionconst.com, martinez-quevedo.com, matasgreekpizza.com, meltonent.com, merletenney.com, mikehillzone.com, milesappraising.com, mloves2sellrealty.com, msn.com, myallegiant.com, mycasasgrandes.com, MYSTICSHOREFG.COM, navitasfitness.com, nenanasd.org, ngoan.com, nhcsd.com, norlightsmontessori.com, northshoresproperties.com, oeinc.org, ohioland4u.com, olsonlawoffice.net, p2000inc.com, palomacervantes.com, palsa.net, patriciapotoy.com, paulettemckoy.com, peabodycorner.com, peggyshovecolumb.com, pinnacleli.com, plasa.com, pridehomebuilders.com, PrimeEstateRealty.net, principleregroup.com, promaxid.com, pwrprod.com, qrmconcrete.com, raptisrealestate.com, re4000.com, realestatevision.net, realridge.com, realstar.com, realteamvj.com, realtymartga.com, reginahaslam.com, rentthelakeshore.com, richconstructioninc.com, richmondcoldstorage.com, riverislandcc.net, rkramer.net, rnbmail.com, robinbender.com, rogershore.com, roggero.com, roknowsrealestate.com, royal1realty.com, royalre.net, rtelectric.net, ryantom.com, sacredheart-florissant.org, saintbrunoschool.com, sberealty.com, seabreezeenterprises.com, selahec.org, selltodaybuytomorrow.com, serenityidaho.com, sevenspringsindiana.com, sheppards.info, sherlockhomesre.com, shownbymichelle.com, sibleypoland.com, skeesicks.net, smoothmag.com, snowwhiteservicesinc.com, socalbrokers.org, sorianogroup.net, sos3.com, southmanproperties.com, springfieldfire.net, sscobra.com, staceypower.com, s-tay.com, stillwaternj.com, stjohnsmg.org, stjohnsvet.com, stmarybashacatholic.org, stricklandrealestate.com, strublera.com, summitautomation.com, svdp-xavier.com, sweetbayproperties.com, synergyrealestate.net, tambercontracting.com, tarheelappraisals.net, teamredtruckrealtor.com, texaslawnlandscape.com, thearagongroupllc.com, themonacorealtygroup.com, theworldwideproperty.com, tldirtwork.com, todayssalonandspa.com, tomwatts.com, topteamrealty.net, triopines.com, tysonlmg.com, upwvsc.org, victoriachristian.org, vilai.com, viocomputers.com, vpappraisal.com, w.cn, wardcrosby.com, waysidefurnitureinc.com, webuypecans.com, westonfire.com, windowslive.com, wkrealestate.net, wyliesrestaurant.com, yhotmail.com, yourkeytc.com, zubs-subs.com

<domain $hotmail>
    use-starttls no
    max-smtp-out 1                                                  # default be nice on concurrent connections
    max-msg-per-connection 1                                       # max 500 mails in one session
    max-rcpt-per-message 1
    max-errors-per-connection 10                                    # avoid 'too long without data command' error
    reuse-ssl-session no

    max-msg-rate 2/m

    bounce-upon-no-mx yes                                           # proper mail domains should have mx
    assume-delivery-upon-data-termination-timeout yes               # avoid duplicate deliveries
    smtp-421-means-mx-unavailable yes
    smtp-553-means-invalid-mailbox yes
    bounce-upon-5xx-greeting true
    connect-timeout 1m
    smtp-greeting-timeout 5m
    data-send-timeout 5m
    retry-after 30m                                                 # typical greylisting period
    bounce-after 3d                                                 # default 4d12h

    smtp-pattern-list blocking-errors
    backoff-max-msg-rate 1/h                                        # send only regular tries during backoff (default unlimited)
    backoff-retry-after 1h,3h,6h,12h                                # retry at least every 20m (default 1h)
    backoff-to-normal-after-delivery yes                            # revert to normal asap (default no)
    backoff-to-normal-after 1h                                      # always revert to normal after 1h (default never)

    dk-sign yes
    dkim-sign yes
    deliver-local-dsn no
</domain>

#####################################################################################################################################
# MSN #
#####################################################################################################################################

# domains that resolve to mx?.hotmail.com
domain-macro msn brennansteil.com, clearybuilding.com, cmsn.com, cumrutownship.com, cypressbenefit.com, highsmith.com, ks-lawfirm.com, libertypartsteam.com, midstateequipment.com, msn.com.ar, omnipress.com, pineridgefarms.com, richland.k12.wi.us, ticominc.com, truckcountry.com, universal-silencer.com, uwdc.org, vitaplus.com, wha.org

<domain $msn>
    use-starttls no
    max-smtp-out 1                                                  # default be nice on concurrent connections
    max-msg-per-connection 1                                       # max 500 mails in one session
    max-rcpt-per-message 1
    max-errors-per-connection 10                                    # avoid 'too long without data command' error
    reuse-ssl-session no

    max-msg-rate 2/m

    bounce-upon-no-mx yes                                           # proper mail domains should have mx
    assume-delivery-upon-data-termination-timeout yes               # avoid duplicate deliveries
    smtp-421-means-mx-unavailable yes
    smtp-553-means-invalid-mailbox yes
    bounce-upon-5xx-greeting true
    connect-timeout 1m
    smtp-greeting-timeout 5m
    data-send-timeout 5m
    retry-after 30m                                                 # typical greylisting period
    bounce-after 3d                                                 # default 4d12h

    smtp-pattern-list blocking-errors
    backoff-max-msg-rate 1/h                                        # send only regular tries during backoff (default unlimited)
    backoff-retry-after 1h,3h,6h,12h                                # retry at least every 20m (default 1h)
    backoff-to-normal-after-delivery yes                            # revert to normal asap (default no)
    backoff-to-normal-after 1h                                      # always revert to normal after 1h (default never)

    dk-sign yes
    dkim-sign yes
    deliver-local-dsn no
</domain>

#####################################################################################################################################
# YAHOO #
#####################################################################################################################################

domain-macro yahoo lyahoo.ca,yahoo.cn,yahoo.co.id,yahoo.co.kr,yahoo.com,yahoo.com.ar,yahoo.com.br,yahoo.com.cn,yahoo.com.mx,yahoo.com.tr,yahoo.com.vn,yahoo.co.nz,yahoo.co.th,yahoo.co.za,yahoo.fr,yahoogroups.co.uk,yahoo.ie,sky.com,ymail.com,rocketmail.com,cccalvin.com

<domain $yahoo>
    use-starttls no
    max-smtp-out 1                                                  # default be nice on concurrent connections
    max-msg-per-connection 1                                       # max 500 mails in one session
    max-rcpt-per-message 1
    max-errors-per-connection 10                                    # avoid 'too long without data command' error
    reuse-ssl-session no

    max-msg-rate 2/m

    bounce-upon-no-mx yes                                           # proper mail domains should have mx
    assume-delivery-upon-data-termination-timeout yes               # avoid duplicate deliveries
    smtp-421-means-mx-unavailable yes
    smtp-553-means-invalid-mailbox yes
    bounce-upon-5xx-greeting true
    connect-timeout 1m
    smtp-greeting-timeout 5m
    data-send-timeout 5m
    retry-after 30m                                                 # typical greylisting period
    bounce-after 3d                                                 # default 4d12h

    smtp-pattern-list blocking-errors
    backoff-max-msg-rate 1/h                                        # send only regular tries during backoff (default unlimited)
    backoff-retry-after 1h,3h,6h,12h                                # retry at least every 20m (default 1h)
    backoff-to-normal-after-delivery yes                            # revert to normal asap (default no)
    backoff-to-normal-after 1h                                      # always revert to normal after 1h (default never)

    dk-sign yes
    dkim-sign yes
    deliver-local-dsn no
</domain>

#####################################################################################################################################
# AOL #
#####################################################################################################################################

# domains that resolve to mailin-0?.mx.aol.com
domain-macro aol aol.com, aim.com, netscape.net, cs.com, mail.com, wmconnect.com, icqmail.com, email.com, usa.com , aol.com.au, aol.com.mx, aol.com.ar, compuserve.com, bruceheath.com, buidarealestate.com, californiaoliveranch.com, casaolga.com, chat-with-me.com, hriscoproperties.com, christina-koski.com, compuserve.com, contech-fr.com, corp.aol.com, crimsondesertrealty.com, csi.com, cutwaterga.com, davidrumpf.net, denisefan.com, depaolimosaic.com, deronnehardware.com, digitalcity.com, dipaolo.net, dipaolobread.com, djdoss.com, dogpeoplerule.com, dsrealestateli.com, easydoesit.com, eichelbergerrealty.net, eillon.com, elainesproperties.com, elecimp.com, exclusivehometeam.com, fieldpaoli.com, frontagerealty.com, games.com, gaolsen.com, georgepattakos.com, getthathousesold.com, goowy.com, graol.com, graydoginvestments.com, greencityrealty.net, haferappraisal.com, halemahaolu.org, icqmail.com, ilike2invest.com, ivieenterprises.net, jeannettedaniel.com, johnsassman.com, jonsells.com, judeybrown.com, kelfamgroup.com, kennysingh.com, koandcompany.com, landquestproperties.net, laraolsen.com, lauraolive.com, letsfundit.net, lilatownsend.com, lisaoliveira.com, luckymail.com, luvgolfing.com, mail2me.com, mapquest.com, mcom.com, missouriappraiser.net, moviefan.com, moviefone.com, mybrevardhome.net, mylifestyleestates.com, myrealtorpa.com, myrealtortonycammarota.com, myrtlepointproperties.com, netbusiness.com, netscape.net, nexusinvestmentsllc.com, ofaolains.com, paolachicago.com, paoli.k12.in.us, paolinicorp.compaolipres.orgolosrestaurant.com, platform-a.com, raabappraisal.com, relegence.com, reneedorsa.com, richardaolson.com, robinwellsrealtor.com, ronkostas.com, rubinny.com, rustonlahomes.com, sadlerdevelopment.com, switched.com, tacoda.com, tagalongunlimited.com, thedryfuseteam.com, thehutchinsonteam.net, thielekaolin.com, udarbe.com, unioncorealty.com, vaughnauctions.com, veachfamily.net, virginiaoldroyd.com, waileaoldblue.com, when.com, wild4music.com, wmconnect.com, wow.com, youronlinerealtor.net, zacharybelil.com, zetage.com

<domain $aol>
    use-starttls no
    max-smtp-out 1                                                  # default be nice on concurrent connections
    max-msg-per-connection 1                                       # max 500 mails in one session
    max-rcpt-per-message 1
    max-errors-per-connection 10                                    # avoid 'too long without data command' error
    reuse-ssl-session no

    max-msg-rate 2/m

    bounce-upon-no-mx yes                                           # proper mail domains should have mx
    assume-delivery-upon-data-termination-timeout yes               # avoid duplicate deliveries
    smtp-421-means-mx-unavailable yes
    smtp-553-means-invalid-mailbox yes
    bounce-upon-5xx-greeting true
    connect-timeout 1m
    smtp-greeting-timeout 5m
    data-send-timeout 5m
    retry-after 30m                                                 # typical greylisting period
    bounce-after 3d                                                 # default 4d12h

    smtp-pattern-list blocking-errors
    backoff-max-msg-rate 1/h                                        # send only regular tries during backoff (default unlimited)
    backoff-retry-after 1h,3h,6h,12h                                # retry at least every 20m (default 1h)
    backoff-to-normal-after-delivery yes                            # revert to normal asap (default no)
    backoff-to-normal-after 1h                                      # always revert to normal after 1h (default never)

    dk-sign yes
    dkim-sign yes
    deliver-local-dsn no
</domain>

#####################################################################################################################################
# GMAIL #
#####################################################################################################################################

# domains that resolve to (alt?.)gmail-smtp-in.l.google.com
domain-macro gmail gmail.com, googlemail.com, bobcat.net, bobcatofhouston.com, bobdavisrealty.com, bobde.net, bobdeis.com, bobdornin.com, bobfirth.com, bobfortner.com, bobnelsonteam.com, bobnur.com, bob-patterson.com, bobpisa.com, bobreidell.com, bobrowpalumbo.com, bobs.org, bobsilvarealtor.com, bobthurlow.com, bobvanallen.com, bobvinson.com, bobwattsrealtor.com, bocabeacon.com, bocajava.com, bocamag.com, bocamuseum.org, bockmonwoody.com, bockrealestate.com, bodemuller.com, bodhiway.org, bodieelectric.com, bodineconstruction.com, boep.org, boerneauto.com, bogany.com, bogerdental.com, boggspaving.com, bogunrealty.com, bohangroup.com, bohmholdt.com, boilingspringlakes.com, boira.net, boiseidrealty.com, boiserealestateguy.com, boisesbestre.com, bojos.com, bokehcorp.com, boleyrealestate.com, bolinger.net, bolivarfamilycare.com, bolsachica.org, boltoninc.com, boltonrealty.com, boltonvet.com, bombay.net, bomglobal.com, boneadventure.com, bonedaddys.com, boneroofingsupply.com, bonfiresf.com, bonhamdental.com, bonifacetool.com, bonitahouse.org, bonitapark.com, bonkinsurance.com, bonnebaker.com, bonnellassociates.com, bonnerhigh.com, bonnevillecompanies.com, bonniebaffa.com, bonniercorp.com, bonningrealestate.com, bonpres.org, bonsallusd.com, bontragerauction.com, boofie.com, bookerauction.com, bookpassage.com, bookstore.com, booksys.com, boomanfloral.com, boomerangsystems.com, boomi.com, booneandsons.com, boonton.org, boontonschools.org, booskaworldwide.com, boothmovers.com, bootjack.com, bordenpestcontrol.com, borderice.com, borderpropertiesinc.com, borderstylo.com, borealtec.com.br, borkholder.com, born.com, bornclinic.com, bornsteinbuilding.com, borough.com, boscobel.org, bosol.com, bosquecountyproperties.com, bossecurity.com, bossierlibrary.org, bossig.com, bossorealty.com, bossrealtygroup.com, bost.org, bosticsugg.com, boston.edu, bostonathenaeum.org, bostonbayside.com, bostonchefs.com, bostoncondogroup.com, bostonconservatory.edu, bostonloft.com, bostonrockgym.com, bostonsbestrealty.com, bostonvineyard.org, bostrom.com, botanics.com

<domain $gmail>
    use-starttls no
    max-smtp-out 1                                                  # default be nice on concurrent connections
    max-msg-per-connection 1                                       # max 500 mails in one session
    max-rcpt-per-message 1
    max-errors-per-connection 10                                    # avoid 'too long without data command' error
    reuse-ssl-session no

    max-msg-rate 2/m

    bounce-upon-no-mx yes                                           # proper mail domains should have mx
    assume-delivery-upon-data-termination-timeout yes               # avoid duplicate deliveries
    smtp-421-means-mx-unavailable yes
    smtp-553-means-invalid-mailbox yes
    bounce-upon-5xx-greeting true
    connect-timeout 1m
    smtp-greeting-timeout 5m
    data-send-timeout 5m
    retry-after 30m                                                 # typical greylisting period
    bounce-after 3d                                                 # default 4d12h

    smtp-pattern-list blocking-errors
    backoff-max-msg-rate 1/h                                        # send only regular tries during backoff (default unlimited)
    backoff-retry-after 1h,3h,6h,12h                                # retry at least every 20m (default 1h)
    backoff-to-normal-after-delivery yes                            # revert to normal asap (default no)
    backoff-to-normal-after 1h                                      # always revert to normal after 1h (default never)

    dk-sign yes
    dkim-sign yes
    deliver-local-dsn no
</domain>

#####################################################################################################################################
# YANDEX #
#####################################################################################################################################

domain-macro yandex yandex.ru, yandex.ua, voliacable.com

<domain $yandex>
    use-starttls no
    max-smtp-out 1                                                  # default be nice on concurrent connections
    max-msg-per-connection 1                                       # max 500 mails in one session
    max-rcpt-per-message 1
    max-errors-per-connection 10                                    # avoid 'too long without data command' error
    reuse-ssl-session no

    max-msg-rate 2/m

    bounce-upon-no-mx yes                                           # proper mail domains should have mx
    assume-delivery-upon-data-termination-timeout yes               # avoid duplicate deliveries
    smtp-421-means-mx-unavailable yes
    smtp-553-means-invalid-mailbox yes
    bounce-upon-5xx-greeting true
    connect-timeout 1m
    smtp-greeting-timeout 5m
    data-send-timeout 5m
    retry-after 30m                                                 # typical greylisting period
    bounce-after 3d                                                 # default 4d12h

    smtp-pattern-list blocking-errors
    backoff-max-msg-rate 1/h                                        # send only regular tries during backoff (default unlimited)
    backoff-retry-after 1h,3h,6h,12h                                # retry at least every 20m (default 1h)
    backoff-to-normal-after-delivery yes                            # revert to normal asap (default no)
    backoff-to-normal-after 1h                                      # always revert to normal after 1h (default never)

    dk-sign yes
    dkim-sign yes
    deliver-local-dsn no
</domain>

#####################################################################################################################################
# OUTLOOK #
#####################################################################################################################################

# domains that resolve to outlook
domain-macro outlook bobmelvin.com, bobpikegroup.com, bocafla.com, bodymedia.com, bo-jac.com, boldinitiative.org, bollin.com, bomusd.k12.ca.us, bomusd.org, bonanzamotors.com, bondfluidaire.com, boone.kyschools.us, bordergrill.com, border-states.com, boston-power.com, bostonunionrealty.com, bownegroup.com, boxlight.com, boyceexcavating.com, boyd.kyschools.us, boydcontreras.com, boyertownymca.org, boykin.com, boyle.kyschools.us, bozzutoinsurance.com, bpcdm.com, bracken.kyschools.us, braddstrelow.com, bradleyrealestate.com, bradleyrealtors.com, bradysandahl.com, branch-isd.org, brandiqinc.com, branstetterlaw.com, breathitt.kyschools.us, breck.kyschools.us, bremertonschools.org, brendasprankel.com, brennerexcavating.com, briar-group.com, brickschools.org, brickstonerealty.net, bridgeheadsoftware.com, bridge-rayn.org, bridgeviewit.com, brightbeginningsinc.org, bristolva.org, britspub.com, brittmorrishomes.com, broaster.com, brocach.com, brokaw.com, broncos.uncfsu.edu, broncs.utpa.edu, brookside-agra.com, brownhardman.com, brownsburg.k12.in.us, brs-llc.com, brunowhite.com, brushresearch.com, bsa.org, bsc.edu, bsschool.org, btginc.com, bua.edu, buckeyeschools.info, buckinghamgreenery.com, bucklarchitects.com, buddyblake.com, buffalowildwings.com, buffingtonhomes.com, buffspec.com, bugmanarkansas.com, buildinginnovationsgroup.com, builtins.com, bulhed.com, bullrealtor.com, bullrun-metal.com, bulmanproducts.com, burgon.com, burkburnettisd.org, burkeproperties.com, burkwald.com, burkwood.com, burnettrealestate.com, burnthickory.com, burrisequipment.com, burrwhite.com, burtonfloor.com, businessjetcenter.com, businessmovesolutions.com, butler.kyschools.us, butlertechnologies.com, buysarasota.com, bvhg.com, bwbcontrols.com, byron.k12.mi.us, caasnm.org, cabarruscollege.edu, cablecominc.com, cabreraservices.com, cabrillomortgage.com, cacoatings.com, cactusrestaurants.com, cactxsurfaces.com, caeonline.com, calabreseandcalabrese.com, cal-chlor.com, calcoastal.org, caldwell.kyschools.us, caldwell-nj.com, caledoniabay.com, calicoweb.com, callcale.com, callcia.com, calljodi.com, calloway.kyschools.us, calsaw.com, calstripsteel.com, camanokeri.com, cambridgemsi.com, cambridgepublicschool.com, cambridgeus.com, camcoconstruction.com, camdencountymuseum.com, camelbackdesertschools.com, cameronbutcher.com, caminoschool.org, campbell.kyschools.us, campbellsurvey.com, campforall.org, campos.com, campronaldmcdonald.org, canalcartage.com, candacerubin.com, cantonagency.com, canyonresources.com, canyonsolutions.com, caodmu.org, capefearcommercial.com, capital.k12.de.us, capitalcleaning.com, capitalcommercial.com, capitalinvestments.net, capitalregroup.com, capitollook.com

<domain $outlook>
    use-starttls no
    max-smtp-out 1                                                  # default be nice on concurrent connections
    max-msg-per-connection 1                                       # max 500 mails in one session
    max-rcpt-per-message 1
    max-errors-per-connection 10                                    # avoid 'too long without data command' error
    reuse-ssl-session no

    max-msg-rate 2/m

    bounce-upon-no-mx yes                                           # proper mail domains should have mx
    assume-delivery-upon-data-termination-timeout yes               # avoid duplicate deliveries
    smtp-421-means-mx-unavailable yes
    smtp-553-means-invalid-mailbox yes
    bounce-upon-5xx-greeting true
    connect-timeout 1m
    smtp-greeting-timeout 5m
    data-send-timeout 5m
    retry-after 30m                                                 # typical greylisting period
    bounce-after 3d                                                 # default 4d12h

    smtp-pattern-list blocking-errors
    backoff-max-msg-rate 1/h                                        # send only regular tries during backoff (default unlimited)
    backoff-retry-after 1h,3h,6h,12h                                # retry at least every 20m (default 1h)
    backoff-to-normal-after-delivery yes                            # revert to normal asap (default no)
    backoff-to-normal-after 1h                                      # always revert to normal after 1h (default never)

    dk-sign yes
    dkim-sign yes
    deliver-local-dsn no
</domain>

#####################################################################################################################################
# USA #
#####################################################################################################################################

# domains that resolve to usa
domain-macro usa boguemachine.com, bootglove.com, brentwoodbank.com, brownjordan.com, budclary.com, c21.com, cabrillocu.com, caicommunications.com, callcarenet.com, callums.com, calpacific.com, cambridgeheart.com, canufly.net, carrolltonbanking.com, cashedge.com, cbcfishman.com, cbcworldwide.com, cbmackey.com, cbpp.org, cccusa.net, ccgcfcu.com, cdrsystems.com, centerbank.com, centinelbank.com, centralbanksavannah.com, centralinteriorsinc.com, centralmetals.com, century21.com, century-health.com, cetco.com, cgsb.com, chartisgroup.com, cherokeestatebank.com, chicagoanodizing.com, chicopeesavings.com, childrenschoice.org, chooseyes.com, chriswilsonrealtor.com, citizensbanktrust.com, citizenssb.com, clairjonesrealty.com, cloud9analytics.com, clovercommunitybank.com, cmpmontana.com, cmshdq.com, cnbbank.com, cnbla.com, cnbofnwpa.com, cnbtopeka.com, cogentusa.net, coldwellbanker.com, collectiveintellect.com, colloid.com, coloeast.com, comlinkusa.net, comm1stcu.org, commandsecurity.com, commercialstate.com, communitybankmissoula.com, communitysavingsbank.com, computer-concepts.com, comspanusa.net, contact-usa.net, controlpanelsusa.net, cornhuskerbank.com, countrybank.com, covenanttrust.com, covingtoncountryclub.com, cpfederal.com, cpvp.com, crestedbuttebank.com, csbcarroll.com, cta.com, cusc.net, cwcu.coop, cynergyusa.net, damantelaw.com, damascuscommbank.com, danielgale.com, datacenterinc.com, datalogics.com, dctfcu.org, deadriver.com, dellaportagroup.com, dibruno.com, digiscape.com, dmtusa.net, dnbfirst.com, donatech.com, doverusa.com, doverusa.net, dukescountysavingsbank.com, dunnsfishfarm.com, eaglepc.net, easternfunding.com, eastsidecommercialbank.com, eastwestmortgage.com, ebicom.net, eccla.com, edgemoorehomes.com, edicwc.com, edmap.com, eldoradosavings.com, elearners.com, electrocontrols.com, elmresources.com, emericon.com, emigroup.com, emimusicpub.com, emiusa.net, emoryfcu.com, employersdirect.com, envoyfinancial.org, era.com, ericryan.com, escousa.net, etusa.net, evertrustbank.com, exatec.biz, farmersagency.com, farmersagent.com, farmersbankva.com, fascofasteners.com, fastband.com, fatspaniel.com, fbmilton.com, fcbank.net, fcboz.com, fcb-yourbank.com, ffl.net, fidelitybanker.com, firestonefinancial.com, firstbanklake.com, firstbanksouthark.com, firstcitizensnational.com, firstcombank.com, firstcommunitysc.com, firstfederalsandl.com, firstmchenry.com, firstmissouri.com, firstmountainbank.com, firstsaversbank.com, firstsouthernbank.net, firststateks.com, florida529plans.com, fnbcanton.com, fnblagrange.com, foodsofvail.com, footprintsusa.net, fpc-consultants.com, framinghambank.com, framinghamcoop.com, freedassociates.com, freedombank.com, fsbanking.com, fsbdover.com, ftbev.com, gannon-scott.com, gay.com, gbcomfort.com, gcfbank.com, gcfcu.org, gcvalves.com, geaugasavings.com, genoaandassociates.com, geograph-ind.com, georgesteel.com, gmi.net, g-m-i.net, gnbonline.com, gokandr.com, goldensecurity.com, goltens.com, gorman-gorman.com, graysonnationalbank.com, greatcompanies.com, greenball.com, grinnellbank.com, gsbbmail.com, gscu.org, gtax.com, guenergy.com, gunnisonbank.com, gusports.com, gwwade.com, hackmanns.com, h-and-k.com, handmark.com, hbaa.com, healthriskpartners.com, heartlandag.com, heartlandcu.org, heathus.com, hedricksavingsbank.com, hendrickscountybank.com, heritagebank.net, herrinsecuritybank.com, hetmanek.com, highlandcommercial.com, hilltopcommunitybank.com, hinghamsavings.com, hmxsportswear.com, hollandtransferco.com, homebankofcalifornia.com, homefedgi.com, homeloanbank.com, hometownbanc.com, hometownbankal.com, horizonusa.net, hotmix.org, houread.org, hps.hubbell.com, hpwhite.com, hrassoc.com, hrlinkstaffing.com, htbrown.com, hubbell.com, hubbell-automation.com, hubbell-premise.com, huntsvillelumber.com, hutchinsonleader.com, hutchisoneng.com, i3solutions.com, ibs.com, idahosupreme.com, idomusa.net, ieiusa.net, ieserve.com, illiniline.com, ilprincipals.org, imagesusa.net, imsenv.com, internet-usa.net, intertek.com, intertek-cb.com, intlfinancebank.com, intralinks.com, ipipeline.com, irusgroup.com, isbalgona.com, isk-industries.com, iwsb.com, jacksoncountybank.com, jakesweeney.com, jaxbank.com, jbfsir.com, jdcu.com, jgiordano.com, jimcookchevrolet.com, journalscene.com, juliabfee.com, kandrindustries.com, kawvalleybank.com, kearneytrust.com, kecu.org, kens5.com, king5.com, kingstonnationalbank.com, ktfcu.org, kvfcu.org, labsphere.com, laccm.org, landisconstruction.com, larkin-grp.com, letsdish.com, lhh.com, libertysavings.com, lilleyinternational.com, loissilva.com, lormet.com, lsfcu.net, magellanbio.com, mainefamilyfcu.com, malagabank.com, maloneheatandair.com, manasquanbank.com, manhattanpharma.com, marioncountysavings.com, markerseven.com, mastermolding.com, mastersvillas.com, matrixusa.net, mavtv.net, mccandlaw.com, mcleodusa.net, mcs-bank.com, mcstorage.com, mdcarchitects.com, mem.com, membersheritage.org, memfirstcu.com, meritusa.net, merrick.com, mesaland.com, metcare.com, metroninc.com, mghassociates.com, millburycu.com, mission-controls.com, mmdusa.net, mobilemarketing.com, moneyonefcu.org, morebankusa.com, msdelta.com, msi-na.com, mssarchitects.com, mtcu.org, multiplexinc.com, murphyobrien.com, mvlegal.org, mvp4me.com, mybankcnb.com, my-broker.com, myfarmersbank.net, mysistersplacedc.org, mytrubank.com, nacps.com, naecu.org, natureusa.net, nbausa.net, nbchgo.com, nbcoxsackie.com, nbnyc.com, neafcu.org, neilenterprises.com, nesec.com, netsouth.cc, netsouth.com, netsurfusa.net, newriverbuilding.com, nhaudubon.org, niederhoffer.com, norcal.usta.com, normansound.com, novatc.org, ochome.com, oldmobank.com, oleen.com, olsten.com, omnibankna.com, oneidabank.com, otisfcu.org, otsusa.net, ourhometownbank.com, out.com, owencom.com, owlwire.com, ozarkbank.com, pacesetterusa.net, pacificearth.com, pacificglobalbank.com, pacificrimusa.net, palmettosouth.com, paragonlighting.com, pataskalabank.com, patient-education.com, patlane.com, pcpusa.net, pctusa.net, pdiusa.net, pdr-usa.net, pedsny.com, peoplesstate.com, pfcu.org, pfeifferelectric.com, pfmills.com, phoenixaccessories.com, phoenixhecht.com, phoenixsavings.com, phs-us.com, pilotgrovesavingsbank.com, pimaheart.com, pinnacol.com, pioneer-bank.com, pioneerbks.com, pira.com, plantationfederal.com, pnbk.com, pngusa.net, polestarmortgage.com, polkcountybank.com, polybrite.com, polytechae.com, porterschapel.com, poshcondos.com, precisionfluorescent.com, premierpower.com, primeair.com, primevest.net, princetoninformation.com, procure.com, promediausa.net, protectusa.net, pro-usa.net, prudentialga.com, prudentialgeorgia.com, prupremier.com, psb-ebank.com, pssckids.org, pt-usa.net, pulsetrading.com, qben.com, qtionline.com, queenstown-bank.com, quoinbank.com, ramseybank.com, realtyexecsrelo.com, realtyexecutives.com, recommind.com, redriverwaterway.com, regententertainment.com, rehabteam.com, remonks.com, reohp.com, rfcu.com, ridgewoodbank.com, rimonthly.com, risris.com, riverfrontcj.com, rjjenkins.com, rmb.com, rmbproducts.com, rmwins.com, rockwoodbank.com, rosellesavings.com, ruralusa.net, rwgusa.com, safety-center.org, sandraweir.com, sanjac.net, sankyo-usa.net, sca-usa.net, scbancorp.com, schaffpiano.com, scottsystem.com, sdc-cs.com, sdiusa.net, seamensbank.com, security-savings.com, selecttelecom.com, semills.com, servicestarusa.net, sewickleysavingsbank.com, sheprealty.com, sherronassoc.com, showersgroup.com, sibor.com, silvarealestate.com, simsburybank.com, skildmfg.com, skylinewindows.com, sloveniansavings.com, smartcu.org, smcpackaging.com, smcschool.org, smra.com, sns.com, somobank.com, sosb-ia.com, sothebysrealty.com, soundbanking.com, soundbanking.net, southerncommercial.net, southernpage.net, southportbank.com, southwestnb.com, spatialinfo.com, sportline.com, sportsdisplay.com, springfieldstate.com, staffingindustry.com, stagnito.com, starelec.com, stargazer.net, statebankonline.net, statemortgage.net, statesavingsbank.com, std-displays.com, stellarfinancial.com, stephensfederalbank.com, sterncassello.com, storserver.com, suburbantire.com, sunbelt-usa.net, superiortouch.com, swc.edu, swfcb.com, T2usa.net, tableausoftware.com, tcbank.com, tcfcu.com, teamcapitalbank.com, teamonejobs.com, tefronusa.net, telenetusa.net, tempteeco.com, teriinc.org, texas.usta.com, texasnational.com, texfed.com, tfharper.com, tfssl.com, theasianbank.com, thebreakawaygroup.com, thecheesecakefactory.com, thewiltonbank.com, thewomensclub.com, thomaswest.com, thycotic.com, tier1inc.com, timent.com, tipcopunch.com, tiusa.net, tli-usa.com, tolerx.com, tolic.com, totalbank.com, totalusa.net, tpayne.com, tpm-usa.net, traditioncm.com, traftonacademy.org, trailsandpaths.com, treasuremart.com, tsbot.com, tsne.org, ttusa.net, turningpointsforchildren.org, txcn.com, ubsmt.com, ucss.com, ulstersavings.com, ultimatesupport.com, umusa.net, unionsla.com, unitedbev.com, unitedcommunitybank.com, unitedprairiebank.com, uplandmutual.com, usa.net, usa-bankers.com, uscopower.com, usfibers.com, usmotors.com, usscofcu.net, usta.com, valleybankmt.com, valleyec.com, vcb.com, vhshc.org, vicfirth.com, vicksburg.com, village-bank.com, vipcommercial.com, viprealty.com, vnbnm.com, vwstores.com, washingtonco-op.com, washingtonelectric.coop, washingtonsav.com, wec.coop, wecenv.com, weissbluth.com, wellmanproducts.com, wellogic.com, westwatercorp.com, wffcu.org, whcu.com, whereibank.com, whitehatsec.com, williamhenrystudio.com, windowco.net, wingzone.com, wjbradley.com, wmls.org, wonicarealtors.com, workcard.com, worldmedia.net, worldtravelservice.com, wrd.state.or.us, wyantdata.com, xcelfcu.org, xfoneusa.net, yaffeco.net, yankeebarnhomes.com, ymcausa.org, youradventureinc.com, zlcs.org, zsz.com

<domain $usa>
    use-starttls no
    max-smtp-out 1                                                  # default be nice on concurrent connections
    max-msg-per-connection 1                                       # max 500 mails in one session
    max-rcpt-per-message 1
    max-errors-per-connection 10                                    # avoid 'too long without data command' error
    reuse-ssl-session no

    max-msg-rate 2/m

    bounce-upon-no-mx yes                                           # proper mail domains should have mx
    assume-delivery-upon-data-termination-timeout yes               # avoid duplicate deliveries
    smtp-421-means-mx-unavailable yes
    smtp-553-means-invalid-mailbox yes
    bounce-upon-5xx-greeting true
    connect-timeout 1m
    smtp-greeting-timeout 5m
    data-send-timeout 5m
    retry-after 30m                                                 # typical greylisting period
    bounce-after 3d                                                 # default 4d12h

    smtp-pattern-list blocking-errors
    backoff-max-msg-rate 1/h                                        # send only regular tries during backoff (default unlimited)
    backoff-retry-after 1h,3h,6h,12h                                # retry at least every 20m (default 1h)
    backoff-to-normal-after-delivery yes                            # revert to normal asap (default no)
    backoff-to-normal-after 1h                                      # always revert to normal after 1h (default never)

    dk-sign yes
    dkim-sign yes
    deliver-local-dsn no
</domain>

#####################################################################################################################################
# FRENCH #
#####################################################################################################################################

# domains that resolve to (alt?.)wanadoo.fr, organe.fr,free.fr
domain-macro french wanadoo.fr, orange.fr, sfr.fr, neuf.fr, online.fr, free.fr, aliceadsl.fr, nic.fr, oleane.net, earthlink.net

<domain $french>
    use-starttls no
    max-smtp-out 1                                                  # default be nice on concurrent connections
    max-msg-per-connection 1                                       # max 500 mails in one session
    max-rcpt-per-message 1
    max-errors-per-connection 10                                    # avoid 'too long without data command' error
    reuse-ssl-session no

    max-msg-rate 2/m

    bounce-upon-no-mx yes                                           # proper mail domains should have mx
    assume-delivery-upon-data-termination-timeout yes               # avoid duplicate deliveries
    smtp-421-means-mx-unavailable yes
    smtp-553-means-invalid-mailbox yes
    bounce-upon-5xx-greeting true
    connect-timeout 1m
    smtp-greeting-timeout 5m
    data-send-timeout 5m
    retry-after 30m                                                 # typical greylisting period
    bounce-after 3d                                                 # default 4d12h

    smtp-pattern-list blocking-errors
    backoff-max-msg-rate 1/h                                        # send only regular tries during backoff (default unlimited)
    backoff-retry-after 1h,3h,6h,12h                                # retry at least every 20m (default 1h)
    backoff-to-normal-after-delivery yes                            # revert to normal asap (default no)
    backoff-to-normal-after 1h                                      # always revert to normal after 1h (default never)

    dk-sign yes
    dkim-sign yes
    deliver-local-dsn no
</domain>

#####################################################################################################################################
# VERIZON #
#####################################################################################################################################

# # domains that resolve to verizon
# domain-macro verizon buylynchburghomes.com, citizencare.org, cognigencorp.com, gte.net, impop.bellatlantic.net, interplay.com, lauer-manguso.com, mci.com, mciworld.com, mdrealtor.org, nlmd.com, provenproducts.com, ubizen.com, uu.net, verizon.com, verizon.net, verizonbusiness.com, verizonmail.com, verizonwireless.com, wcom.net

# <domain $verizon>
    #   use-starttls no
    #   max-smtp-out 1
    #   max-msg-per-connection 1
    #   max-rcpt-per-message 1
    #   max-errors-per-connection 10
    #   reuse-ssl-session no

    #   # max-msg-rate 2/m

    #   bounce-upon-no-mx yes
    #   assume-delivery-upon-data-termination-timeout yes               # avoid duplicate deliveries
    #   smtp-421-means-mx-unavailable yes
    #   smtp-553-means-invalid-mailbox yes
    #   bounce-upon-5xx-greeting true
    #   connect-timeout 1m
    #   smtp-greeting-timeout 5m
    #   data-send-timeout 5m
    #   retry-after 30m
    #   bounce-after 3d

    #   smtp-pattern-list blocking-errors
    #   #backoff-max-msg-rate 1/h                                        # send only regular tries during backoff (default unlimited)
    #   backoff-max-msg-rate unlimited
    #   backoff-retry-after 1h,3h,6h,12h
    #   backoff-to-normal-after-delivery yes
    #   backoff-to-normal-after 1h

    #   dk-sign yes
    #   dkim-sign yes
    #   deliver-local-dsn no
    # </domain>

#####################################################################################################################################
# I.UA #
#####################################################################################################################################

domain-macro iua i.ua

<domain $iua>
    use-starttls no
    max-smtp-out 1                                                  # default be nice on concurrent connections
    max-msg-per-connection 1                                       # max 500 mails in one session
    max-rcpt-per-message 1
    max-errors-per-connection 10                                    # avoid 'too long without data command' error
    reuse-ssl-session no

    max-msg-rate 2/m

    bounce-upon-no-mx yes                                           # proper mail domains should have mx
    assume-delivery-upon-data-termination-timeout yes               # avoid duplicate deliveries
    smtp-421-means-mx-unavailable yes
    smtp-553-means-invalid-mailbox yes
    bounce-upon-5xx-greeting true
    connect-timeout 1m
    smtp-greeting-timeout 5m
    data-send-timeout 5m
    retry-after 30m                                                 # typical greylisting period
    bounce-after 3d                                                 # default 4d12h

    smtp-pattern-list blocking-errors
    backoff-max-msg-rate 1/h                                        # send only regular tries during backoff (default unlimited)
    backoff-retry-after 1h,3h,6h,12h                                # retry at least every 20m (default 1h)
    backoff-to-normal-after-delivery yes                            # revert to normal asap (default no)
    backoff-to-normal-after 1h                                      # always revert to normal after 1h (default never)

    dk-sign yes
    dkim-sign yes
    deliver-local-dsn no
</domain>

#####################################################################################################################################
# DEFAULT DOMAIN SETTINGS #
#####################################################################################################################################

<domain *>
    use-starttls no
    max-smtp-out 1                                                  # default be nice on concurrent connections
    max-msg-per-connection 1                                       # max 500 mails in one session
    max-rcpt-per-message 1
    max-errors-per-connection 10                                    # avoid 'too long without data command' error
    reuse-ssl-session no

    max-msg-rate 2/m

    bounce-upon-no-mx yes                                           # proper mail domains should have mx
    assume-delivery-upon-data-termination-timeout yes               # avoid duplicate deliveries
    smtp-421-means-mx-unavailable yes
    smtp-553-means-invalid-mailbox yes
    bounce-upon-5xx-greeting true
    connect-timeout 1m
    smtp-greeting-timeout 5m
    data-send-timeout 5m
    retry-after 30m                                                 # typical greylisting period
    bounce-after 3d                                                 # default 4d12h

    smtp-pattern-list blocking-errors
    backoff-max-msg-rate 1/h                                        # send only regular tries during backoff (default unlimited)
    backoff-retry-after 1h,3h,6h,12h                                # retry at least every 20m (default 1h)
    backoff-to-normal-after-delivery yes                            # revert to normal asap (default no)
    backoff-to-normal-after 1h                                      # always revert to normal after 1h (default never)

    dk-sign yes
    dkim-sign yes
    deliver-local-dsn no
</domain>

#####################################################################################################################################
# END Section 4: DOMAIN SETTINGS
#####################################################################################################################################

#####################################################################################################################################
# Section 5: SMTP PATTERN SETTINGS
#####################################################################################################################################

<smtp-pattern-list common-errors>
    reply /generating high volumes of.* complaints from AOL/    mode=backoff
    reply /Excessive unknown recipients - possible Open Relay/  mode=backoff
    reply /^421 .* too many errors/                             mode=backoff
    reply /blocked.*spamhaus/                                   mode=backoff
    reply /451 Rejected/                                        mode=backoff
</smtp-pattern-list>

<smtp-pattern-list blocking-errors>

    #AOL Errors
    reply /421 .* SERVICE NOT AVAILABLE/ mode=backoff
    reply /generating high volumes of.* complaints from AOL/ mode=backoff
    reply /554 .*aol.com/ mode=backoff
    reply /421dynt1/ mode=backoff
    reply /HVU:B1/ mode=backoff
    reply /DNS:NR/ mode=backoff
    reply /RLY:NW/ mode=backoff
    reply /DYN:T1/ mode=backoff
    reply /RLY:BD/ mode=backoff
    reply /RLY:CH2/ mode=backoff
    #
    #Yahoo Errors
    reply /421 .* Please try again later/ mode=backoff
    reply /421 Message temporarily deferred/ mode=backoff
    reply /VS3-IP5 Excessive unknown recipients/ mode=backoff
    reply /VSS-IP Excessive unknown recipients/ mode=backoff
    #
    # The following 4 Yahoo errors may be very common
    # Using them may result in high use of backoff mode
    #
    reply /\[GL01\] Message from/ mode=backoff
    reply /\[TS01\] Messages from/ mode=backoff
    reply /\[TS02\] Messages from/ mode=backoff
    reply /\[TS03\] All messages from/ mode=backoff
    #
    #Hotmail Errors
    reply /exceeded the rate limit/ mode=backoff
    reply /exceeded the connection limit/ mode=backoff
    reply /Mail rejected by Windows Live Hotmail for policy reasons/ mode=backoff
    reply /mail.live.com\/mail\/troubleshooting.aspx/ mode=backoff
    #
    #Adelphia Errors
    reply /421 Message Rejected/ mode=backoff
    reply /Client host rejected/ mode=backoff
    reply /blocked using UCEProtect/ mode=backoff
    #
    #Road Runner Errors
    reply /Mail Refused/ mode=backoff
    reply /421 Exceeded allowable connection time/ mode=backoff
    reply /amIBlockedByRR/ mode=backoff
    reply /block-lookup/ mode=backoff
    reply /Too many concurrent connections from source IP/ mode=backoff
    #
    #General Errors
    reply /too many/ mode=backoff
    reply /Exceeded allowable connection time/ mode=backoff
    reply /Connection rate limit exceeded/ mode=backoff
    reply /refused your connection/ mode=backoff
    reply /try again later/ mode=backoff
    reply /try later/ mode=backoff
    reply /550 RBL/ mode=backoff
    reply /TDC internal RBL/ mode=backoff
    reply /connection refused/ mode=backoff
    reply /please see www.spamhaus.org/ mode=backoff
    reply /Message Rejected/ mode=backoff
    reply /refused by antispam/ mode=backoff
    reply /Service not available/ mode=backoff
    reply /currently blocked/ mode=backoff
    reply /locally blacklisted/ mode=backoff
    reply /not currently accepting mail from your ip/ mode=backoff
    reply /421.*closing connection/ mode=backoff
    reply /421.*Lost connection/ mode=backoff
    reply /476 connections from your host are denied/ mode=backoff
    reply /421 Connection cannot be established/ mode=backoff
    reply /421 temporary envelope failure/ mode=backoff
    reply /421 4.4.2 Timeout while waiting for command/ mode=backoff
    reply /450 Requested action aborted/ mode=backoff
    reply /550 Access denied/ mode=backoff
    reply /exceeded the rate limit/ mode=backoff
    reply /421rlynw/ mode=backoff
    reply /permanently deferred/ mode=backoff
    reply /\d+\.\d+\.\d+\.\d+ blocked/ mode=backoff
    reply /www\.spamcop\.net\/bl\.shtml/ mode=backoff
    reply /generating high volumes of.* complaints from AOL/    mode=backoff
    reply /Excessive unknown recipients - possible Open Relay/  mode=backoff
    reply /^421 .* too many errors/                             mode=backoff
    reply /blocked.*spamhaus/                                   mode=backoff
    reply /451 Rejected/                                        mode=backoff
</smtp-pattern-list>

#####################################################################################################################################
# END Section 5: SMTP PATTERN SETTINGS
#####################################################################################################################################

#####################################################################################################################################
# Section 6: LOG AND SPOOL SETTINGS
#####################################################################################################################################

log-file /var/log/pmta/log        # logrotate is used for rotation

# All logs
<acct-file /var/log/pmta/acct.csv>
move-interval 5m
max-size 25M
delete-after 7d
</acct-file>

# HardBounce logs
<acct-file /var/log/pmta/hardbounces.csv>
records r
records rb
record-fields r *
record-fields rb *
move-interval 5m
max-size 25M
delete-after 7d
</acct-file>

# SoftBounce logs
<acct-file /var/log/pmta/softbounces.csv>
records t
record-fields t *
move-interval 5m
max-size 25M
delete-after 7d
</acct-file>

# Delivery log
<acct-file /var/log/pmta/success.csv>
records d
record-fields d *
move-interval 5m
max-size 25M
delete-after 7d
</acct-file>

#####################################################################################################################################
# BEGIN: OTHER OPTIONS
#####################################################################################################################################

sync-msg-create false
sync-msg-update false
run-as-root no

#####################################################################################################################################
# SPOOL DIRECTORIES
#####################################################################################################################################

<spool /var/spool/pmta>
deliver-only no
delete-file-holders yes
</spool>

#####################################################################################################################################
# END
#####################################################################################################################################
EOF