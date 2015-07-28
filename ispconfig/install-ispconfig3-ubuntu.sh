#!/bin/bash
## Install ISPConfig3 on Ubuntu 14.04 64Bits
## Author: Nilton OS blog.linuxpro.com.br
## http://blog.linuxpro.com.br/posts/instalando-ispconfig3-no-ubuntu-1404.html
## http://www.howtoforge.com/perfect-server-ubuntu-14.04-apache2-php-mysql-pureftpd-bind-dovecot-ispconfig-3-p2


dpkg-reconfigure dash

service apparmor stop
update-rc.d -f apparmor remove
apt-get remove -y apparmor apparmor-utils

service sendmail stop; update-rc.d -f sendmail remove

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


service spamassassin stop
update-rc.d -f spamassassin remove

apt-get install -y apache2 apache2-utils libapache2-mod-php5 php5
apt-get install -y php5-common php5-gd php5-mysql php5-imap phpmyadmin php5-cli 
apt-get install -y php5-cgi libapache2-mod-fcgid apache2-suexec php-pear php-auth 
apt-get install -y php5-mcrypt mcrypt php5-imagick imagemagick libapache2-mod-suphp 
apt-get install -y libruby libapache2-mod-python php5-curl php5-intl php5-memcache 
apt-get install -y php5-memcached php5-ming php5-ps php5-pspell php5-recode php5-snmp 
apt-get install -y php5-sqlite php5-tidy php5-xmlrpc php5-xsl memcached

 
apt-get install -y libapache2-mod-fastcgi php5-fpm php5-xcache
apt-get install -y pure-ftpd-common pure-ftpd-mysql quota quotatool libclass-dbi-mysql-perl
apt-get install -y bind9 dnsutils vlogger webalizer awstats geoip-database
apt-get install -y build-essential autoconf automake1.9 libtool flex bison debhelper binutils-gold

php5enmod mcrypt

a2enmod suexec rewrite ssl actions include cgi
a2enmod dav_fs dav auth_digest
a2enmod actions fastcgi alias


sed -i 's|VIRTUALCHROOT=false|VIRTUALCHROOT=true|' /etc/default/pure-ftpd-common
sed -i 's|application/x-ruby|#application/x-ruby|' /etc/mime.types

echo 1 > /etc/pure-ftpd/conf/TLS
mkdir -p /etc/ssl/private/
openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem
chmod 600 /etc/ssl/private/pure-ftpd.pem
service pure-ftpd-mysql restart


rm -f /etc/cron.d/awstats


echo '<IfModule mod_suphp.c>
    #<FilesMatch "\.ph(p3?|tml)$">
    #    SetHandler application/x-httpd-suphp
    #</FilesMatch>
        AddType application/x-httpd-suphp .php .php3 .php4 .php5 .phtml
        suPHP_AddHandler application/x-httpd-suphp

    <Directory />
        suPHP_Engine on
    </Directory>

    # By default, disable suPHP for debian packaged web applications as files
    # are owned by root and cannot be executed by suPHP because of min_uid.
    <Directory /usr/share>
        suPHP_Engine off
    </Directory>

# # Use a specific php config file (a dir which contains a php.ini file)
#       suPHP_ConfigPath /etc/php5/cgi/suphp/
# # Tells mod_suphp NOT to handle requests with the type <mime-type>.
#       suPHP_RemoveHandler <mime-type>
</IfModule>' > /etc/apache2/mods-available/suphp.conf


service apache2 restart


cd /tmp
wget http://www.ispconfig.org/downloads/ISPConfig-3-stable.tar.gz
tar xfz ISPConfig-3-stable.tar.gz
cd ispconfig3_install/install/
php -q install.php

