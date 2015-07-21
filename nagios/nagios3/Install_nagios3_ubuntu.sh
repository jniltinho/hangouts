#!/bin/bash
## Script de Instalacao Nagios3 no Ubuntu 14.04 32Bits
## Autor: Nilton OS <jniltinho@gmail.com>
## Versao 0.2 12-07-2015

## Links:
## http://www.nagiosql.org/documentation.html

## Instalar Ambiente Apache2/PHP/Mysql

apt-get update
apt-get upgrade

## Reconfigure o Dash
dpkg-reconfigure dash
echo 'LC_ALL="en_US.utf8"' >>/etc/environment
## Antes de prosseguir reinicie o Servidor

apt-get install -y ssh openssh-server vim-nox ntp ntpdate
service apparmor stop
update-rc.d -f apparmor remove
apt-get remove apparmor apparmor-utils -y

apt-get install -y postfix mysql-client mysql-server openssl binutils sudo

apt-get install -y unzip bzip2 nomarch apt-listchanges libwww-perl liburi-perl
apt-get install -y libauthen-sasl-perl daemon libio-string-perl mrtg
apt-get install -y libio-socket-ssl-perl libnet-ident-perl zip libnet-dns-perl

apt-get install -y apache2 apache2-doc apache2-utils libapache2-mod-php5 
apt-get install -y php5 php5-common php5-gd php5-mysql php5-imap php5-cli 
apt-get install -y php5-cgi libapache2-mod-fcgid php-pear 
apt-get install -y php-auth php5-mcrypt mcrypt php5-imagick imagemagick
apt-get install -y php5-curl php5-intl memcached snmp libssh2-php
apt-get install -y php5-memcache php5-memcached php5-ming 
apt-get install -y php5-ps php5-pspell php5-recode php5-snmp 
apt-get install -y php5-sqlite php5-tidy php5-xmlrpc php5-xsl
apt-get install -y geoip-database libclass-dbi-mysql-perl

sed -i "s|;date.timezone =|date.timezone = 'America\/Sao_Paulo'|" /etc/php5/apache2/php.ini
php5enmod mcrypt
a2enmod suexec rewrite ssl actions include cgi
service apache2 restart


## Instalar o Nagios3
apt-get install -y nagios3 nagios-nrpe-plugin
service nagios3 stop
dpkg-statoverride --update --add nagios www-data 2710 /var/lib/nagios3/rw
dpkg-statoverride --update --add nagios nagios 751 /var/lib/nagios3
dpkg-statoverride --update --add nagios www-data 2710 /var/lib/nagios3/spool/checkresults
dpkg-statoverride --update --add nagios nagios 751 /var/lib/nagios3/spool
chown -R nagios:www-data /var/lib/nagios3/rw
usermod -a -G nagios www-data
sed -i "s|check_external_commands=0|check_external_commands=1|" /etc/nagios3/nagios.cfg
service nagios3 start

## Vamos agora Reiniciar o Servidor

## Depois que o Servidor Subir acesse o ip do Servidor via HTTP
## http://ip_do_servidor/nagios3/

## Install pnp4nagios
apt-get install -y pnp4nagios pnp4nagios-bin pnp4nagios-web shinken-module-broker-npcdmod

sed -i 's|RUN="no"|RUN="yes"|' /etc/default/npcd
sed -i 's|process_performance_data=0|process_performance_data=1|' /etc/nagios3/nagios.cfg
sed -i 's|#host_perfdata_command=process-host-perfdata|host_perfdata_command=process-host-perfdata|' /etc/nagios3/nagios.cfg
sed -i 's|#service_perfdata_command=process-service-perfdata|service_perfdata_command=process-service-perfdata|' /etc/nagios3/nagios.cfg

update-rc.d npcd defaults
service npcd start

## Instalar o novo tema (arana_style)
cd /root/
wget http://downloads.sourceforge.net/project/arana-nagios/arana_style-1.0for-Nagios3x-ENG.zip
unzip arana_style-1.0for-Nagios3x-ENG.zip
rm -f arana_style-1.0for-Nagios3x-ENG.zip
mv /etc/nagios3/stylesheets /etc/nagios3/stylesheets.old
mv arana_style/stylesheets /etc/nagios3/
cp -aR /usr/share/nagios3/htdocs /usr/share/nagios3/htdocs.old

sed -i 's|/nagios|/nagios3|g' arana_style/menu.html
sed -i 's|/nagios|/nagios3|g' arana_style/sidebar.html
sed -i 's|/nagios|/nagios3|g' arana_style/top.html
cp -aR arana_style/* /usr/share/nagios3/htdocs/
rm -rf arana_style

## Agora vamos Instalar o NagiosQL,  versão 3.2.0
cd /usr/share/nagios3/htdocs/

wget http://sourceforge.net/projects/nagiosql/files/nagiosql/NagiosQL%203.2.0/nagiosql_320.tar.gz
tar -zxvf nagiosql_320.tar.gz
mv nagiosql32 nagiosQL
wget http://sourceforge.net/projects/nagiosql/files/nagiosql/NagiosQL%203.2.0/nagiosql_320_service_pack_2_additional_fixes_only.zip
unzip nagiosql_320_service_pack_2_additional_fixes_only.zip
cp -aR NagiosQL_3.2.0_SP2/* nagiosQL/
rm -rf NagiosQL_3.2.0_SP2 nagiosql_320_service_pack_2_additional_fixes_only.zip nagiosql_320.tar.gz
chown -R www-data:www-data nagiosQL
chown -R www-data:www-data nagiosQL/*

mkdir /etc/nagiosql

## Nagios Main Configuration Files
chgrp www-data /etc/nagios3
chgrp www-data /etc/nagios3/nagios.cfg
chgrp www-data /etc/nagios3/cgi.cfg
chmod 775 /etc/nagios3
chmod 664 /etc/nagios3/nagios.cfg
chmod 664 /etc/nagios3/cgi.cfg

## NagiosQL Configuration
chmod 6755 /etc/nagiosql
chown www-data:nagios /etc/nagiosql
chmod 6755 /etc/nagiosql/hosts
chown www-data:nagios /etc/nagiosql/hosts
chmod 6755 /etc/nagiosql/services
chown www-data:nagios /etc/nagiosql/services   

## NagiosQL Backup Configuration 
chmod 6755 /etc/nagiosql/backup
chown www-data:nagios /etc/nagiosql/backup
chmod 6755 /etc/nagiosql/backup/hosts
chown www-data:nagios /etc/nagiosql/backup/hosts
chmod 6755 /etc/nagiosql/backup/services
chown www-data:nagios /etc/nagiosql/backup/services

## Amend already existing files
chmod 644 /etc/nagiosql/*.cfg
chown www-data:nagios /etc/nagiosql/*.cfg
chmod 644 /etc/nagiosql/hosts/*.cfg
chown www-data:nagios /etc/nagiosql/hosts/*.cfg   
chmod 644 /etc/nagiosql/services/*.cfg
chown www-data:nagios /etc/nagiosql/services/*.cfg

## The Nagios binary must be executable by the Apache user:
chown nagios:www-data /usr/sbin/nagios3
chmod 750 /usr/sbin/nagios3

chown nagios:www-data /var/lib/nagios3/rw/nagios.cmd
chmod 660 /var/lib/nagios3/rw/nagios.cmd

##chown -R www-data:www-data /etc/nagiosql
##chown -R www-data:www-data /etc/nagiosql/*

## Ajustando permissoes do PID
/etc/init.d/nagios3 stop
rm -rf /var/run/nagios3
sed -i "s|chown nagios:nagios /var/run/nagios3|chown nagios:www-data /var/run/nagios3|" /etc/init.d/nagios3
/etc/init.d/nagios3 start

## Depois de todos esses passos voce deve acessar o navegador no seguinte endereco
## http://ip_do_servidor/nagios3/nagiosQL/
## Vai aparecer uma tela de instalacao do NagiosQL

echo "Os passos abaixo voce precisar executar depois de configurar o NagiosQL via Web"
echo "A instalacao do Nagios e NagiosQL termina aqui, por favor leia o final desse arquivo"
exit

## Apos a instalacao do NagiosQL execute passos abaixo, nao esqueca de colocar o nome da base do nagiosQL
## nagiosql, e a a senha do admin 123456 e o nome do admin (admin)

cd /root
### Configurar o CFG do Nagios
wget https://gist.githubusercontent.com/jniltinho/44daaf20b1ec10d66c03/raw/8a58dae3af81e7e9be68987e98602066a7ab581e/nagios.cfg
cp /etc/nagios3/nagios.cfg /etc/nagios3/nagios.cfg.old
cat nagios.cfg > /etc/nagios3/nagios.cfg
rm -f nagios.cfg

### Configurar a Base de Dados
cd /root/
wget https://gist.githubusercontent.com/jniltinho/44daaf20b1ec10d66c03/raw/6ed0807e5180e1f487da997fa8ac96e0f720d587/nagiosql-20150712_1918.sql
mysql -p < nagiosql-20150712_1918.sql
rm -f nagiosql-20150712_1918.sql