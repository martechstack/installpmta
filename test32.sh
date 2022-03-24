# 3. ADD rule on plex:
if grep -q '88.88.888.888' file.txt;
then
  echo 'IP already in file..';
else
  sed -i 's/function __construct($host, $port = 22, $timeout = 10)
                 {/function __construct($host, $port = 22, $timeout = 10)
                        {
                         	 /**100 First Server */
                            if ($host == "88.88.888.888") {
                                $port = 1122;
                            }

/g' /etc/ssh/sshd_config

fi