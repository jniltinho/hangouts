#!/bin/bash
## Install ISPConfig3 on Ubuntu 14.04 64Bits
## Author: Nilton OS blog.linuxpro.com.br
## http://blog.linuxpro.com.br/posts/instalando-ispconfig3-no-ubuntu-1404.html
## http://www.howtoforge.com/the-perfect-server-ubuntu-14.04-nginx-bind-mysql-php-postfix-dovecot-and-ispconfig3-p2


dpkg-reconfigure dash

service apparmor stop
update-rc.d -f apparmor remove
apt-get remove -y apparmor apparmor-utils

service sendmail stop; update-rc.d -f sendmail remove

apt-get update
apt-get install -y vim-nox ssh openssh-server

apt-get install -y postfix postfix-mysql mysql-client
apt-get install -y mysql-server openssl getmail4 binutils dovecot-imapd
apt-get install -y dovecot-pop3d dovecot-mysql dovecot-sieve sudo ntp ntpdate


sed -i 's|bind-address|#bind-address|' /etc/mysql/my.cnf

## Ajustando o arquivo /etc/postfix/master.cf do Postfix
sed -i 's|#submission|submission|' /etc/postfix/master.cf
sed -i 's|#  -o syslog_name=postfix/submission|  -o syslog_name=postfix/submission|' /etc/postfix/master.cf
sed -i 's|#  -o smtpd_tls_security_level=encrypt|  -o smtpd_tls_security_level=encrypt|' /etc/postfix/master.cf
sed -i 's|#  -o smtpd_sasl_auth_enable=yes|  -o smtpd_sasl_auth_enable=yes|' /etc/postfix/master.cf
sed -i 's|#  -o smtpd_reject_unlisted_recipient=no|  -o smtpd_client_restrictions=permit_sasl_authenticated,reject|' /etc/postfix/master.cf

sed -i 's|#smtps|smtps|' /etc/postfix/master.cf
sed -i 's|#  -o syslog_name=postfix/smtps|  -o syslog_name=postfix/smtps|' /etc/postfix/master.cf
sed -i 's|#  -o smtpd_tls_wrappermode=yes|  -o smtpd_tls_wrappermode=yes|' /etc/postfix/master.cf
sed -i 's|#  -o smtpd_sasl_auth_enable=yes|  -o smtpd_sasl_auth_enable=yes|' /etc/postfix/master.cf
sed -i 's|#  -o smtpd_reject_unlisted_recipient=no|  -o smtpd_client_restrictions=permit_sasl_authenticated,reject|' /etc/postfix/master.cf

service postfix restart
service mysql restart


apt-get install -y amavisd-new spamassassin clamav clamav-daemon zoo libnet-ldap-perl
apt-get install -y unzip bzip2 arj nomarch lzop cabextract apt-listchanges
apt-get install -y libauthen-sasl-perl daemon libio-string-perl 
apt-get install -y libio-socket-ssl-perl libnet-ident-perl zip libnet-dns-perl

apt-get install -y nginx

service spamassassin stop
update-rc.d -f spamassassin remove

apt-get install -y php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap 
apt-get install -y php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-snmp php-apc
apt-get install -y php5-sqlite php5-tidy php5-xmlrpc php5-xsl snmp php5-mcrypt php5-fpm fcgiwrap
apt-get install -y pure-ftpd-common pure-ftpd-mysql quota quotatool build-essential
apt-get install -y vlogger webalizer awstats geoip-database libclass-dbi-mysql-perl
apt-get install -y autoconf automake1.9 libtool flex bison debhelper binutils-gold

php5enmod mcrypt


sed -i 's|;cgi.fix_pathinfo=1|cgi.fix_pathinfo=0|' /etc/php5/fpm/php.ini
sed -i 's|;date.timezone =|date.timezone="America/Sao_Paulo"|' /etc/php5/fpm/php.ini

service php5-fpm restart
service nginx start

sed -i 's|VIRTUALCHROOT=false|VIRTUALCHROOT=true|' /etc/default/pure-ftpd-common


echo 1 > /etc/pure-ftpd/conf/TLS
mkdir -p /etc/ssl/private/
openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem
chmod 600 /etc/ssl/private/pure-ftpd.pem
service pure-ftpd-mysql restart


rm -f /etc/cron.d/awstats

## Install PHPMyadmin 4.2.2
wget http://ufpr.dl.sourceforge.net/project/phpmyadmin/phpMyAdmin/4.2.2/phpMyAdmin-4.2.2-all-languages.tar.bz2
tar xvf phpMyAdmin-4.2.2-all-languages.tar.bz2
rm -f phpMyAdmin-4.2.2-all-languages.tar.bz2
mv phpMyAdmin-4.2.2-all-languages /usr/share/phpmyadmin

echo '<?php
$i = 0;
$i++;
$cfg["Servers"][$i]["auth_type"] = "cookie";
$myserver = split("/", strtolower($_SERVER["SERVER_SOFTWARE"]));
if($myserver[0] == "nginx"){ $cfg["Servers"][$i]["auth_type"] = "http"; }
$cfg["Servers"][$i]["host"] = "localhost";
$cfg["Servers"][$i]["connect_type"] = "tcp";
$cfg["Servers"][$i]["compress"] = false;
$cfg["Servers"][$i]["extension"] = "mysqli";
$cfg["Servers"][$i]["AllowNoPassword"] = false;
$cfg["blowfish_secret"] = "{^QP+-(3mlHy+Gd~FE3mN{gIATs^1lX+T=KVYv{ubK*U0V";
$cfg["UploadDir"] = "";
$cfg["SaveDir"] = "";

if ($_SERVER["SERVER_PORT"] == 80){$cfg["Servers"][$i]["AllowRoot"] = FALSE;
$cfg["Servers"][$i]["hide_db"] = "(information_schema|phpmyadmin|mysql|test)";
}
$cfg["DefaultLang"] = "en";
$cfg["DefaultLang"] = "pt_BR";
?>' > /usr/share/phpmyadmin/config.inc.php


echo 'location /phpmyadmin {
               root /usr/share/;
               index index.php index.html index.htm;
               location ~ ^/phpmyadmin/(.+\.php)$ {
                       try_files $uri =404;
                       root /usr/share/;
                       fastcgi_pass unix:/var/run/php5-fpm.sock;
                       fastcgi_index index.php;
                       fastcgi_param SCRIPT_FILENAME $request_filename;
                       include /etc/nginx/fastcgi_params;
                       fastcgi_param PATH_INFO $fastcgi_script_name;
                       fastcgi_buffer_size 128k;
                       fastcgi_buffers 256 4k;
                       fastcgi_busy_buffers_size 256k;
                       fastcgi_temp_file_write_size 256k;
                       fastcgi_intercept_errors on;
               }
  location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
             root /usr/share/;
  }
}
location /phpMyAdmin {
        rewrite ^/* /phpmyadmin last;
}' > /etc/nginx/phpmyadmin.conf



service php5-fpm restart

cd /tmp
wget http://www.ispconfig.org/downloads/ISPConfig-3-stable.tar.gz
tar xfz ISPConfig-3-stable.tar.gz
cd ispconfig3_install/install/
php -q install.php

echo "Agora vamos reiniciar o Servidor ..."
sleep 5
init 6
