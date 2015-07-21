#!/usr/bin/python
# -*- coding: utf-8 -*-
## 20-07-2015
## Autor Nilton OS <jniltinho@gmail.com>
## Version 0.4
## Script para Envio de SMS usando Zenvia
## Colocar na pasta /usr/lib/nagios/plugins/
## Adicionar o Command no NagiosQL

usage = '''
define command {
	command_name                   	host-notify-by-sms
	command_line                   	/usr/bin/python $USER1$/sendsms.py $CONTACTPAGER$ '$NOTIFICATIONTYPE$: $HOSTNAME$ is $HOSTSTATE$'
	register                       	1
}	

define command {
	command_name                   	notify-by-sms
	command_line                   	/usr/bin/python $USER1$/sendsms.py $CONTACTPAGER$ 'NagiosNew: $NOTIFICATIONTYPE$: $HOSTNAME$: $SERVICEDESC$ is $SERVICESTATE$'
	register                       	1
}	
'''

import sys, datetime, time, httplib
from urllib2 import quote

account = "loginzenvia";
#Informe sua senha human gateway
code = "senhazenvia";

msg_log = ("%s send mobile: %s, send message: %s\n") %(time.strftime('%b %d %H:%M:%S'), sys.argv[1], sys.argv[2])
salve_log = open("/tmp/sms.log","a+"); salve_log.write(msg_log); salve_log.close()

now = datetime.datetime.now()

#o primeiro argumento eh o celular de destino da mensagem que o Nagios insere automaticamente
mobile = sys.argv[1]

#o segundo argumento eh o texto do sms
rawmsg = sys.argv[2] 

#o texto deve ser codificado para ser enviado na URL
text_msg = quote(rawmsg)


url_msg = "dispatch=send&account=%s&code=%s&to=%s&msg=%s:%s-%s" %(account,code,mobile,now.hour,now.minute,text_msg)



httpServ = httplib.HTTPConnection("system.human.com.br", 8080)
httpServ.connect()
httpServ.request('GET', "/GatewayIntegration/msgSms.do?" + url_msg)
response = httpServ.getresponse()
httpServ.close()
