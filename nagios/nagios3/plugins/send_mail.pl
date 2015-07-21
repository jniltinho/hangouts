#!/usr/bin/perl -w
# Colocar na Pasta /usr/lib/nagios/plugins/
# Wriiten by Rob Moss, 2005-10-09
# coding@mossko.com
#
# A replacement for Nagios's basic mail system which relies on /bin/mailx and local sendmail config
#
# To use this, just replace the entries in commands.cfg and update your hosts and services from the default "notify-by-email" to use the specific host-notify-by-email or service-notify-by-email
#
# I put this in the plugins directory /usr/local/nagios/libexec but you can put it anywhere. Just update the path

# commands.cfg
#define command{
#	command_name	host-notify-by-email
#	command_line	$USER1$/send_mail.pl -n "HOST $NOTIFICATIONTYPE$" -h "$HOSTNAME$"  -s "$HOSTSTATE$" -a "$HOSTADDRESS$" -i "$HOSTOUTPUT$" -d "$LONGDATETIME$" -e "$CONTACTEMAIL$"
#}
#
#define command{
#	command_name	service-notify-by-email
#	command_line	$USER1$/send_mail.pl -n "$NOTIFICATIONTYPE$" -h "$HOSTNAME$" -s "$SERVICESTATE$" -a "$HOSTADDRESS$" -i "$SERVICEDESC$ - $SERVICEOUTPUT$ - $SERVICECHECKCOMMAND$" -d "$LONGDATETIME$" -e "$CONTACTEMAIL$"
#}

# contacts.cfg
#define contact{
#	contact_name					contact
#	host_notification_commands		host-notify-by-email
#	service_notification_commands	service-notify-by-email
#	email							email@address.com
#}


use strict;
use Net::SMTP;
use Getopt::Std;

my $mailhost	=	'nagios.linuxpro.com.br';
my $maildomain	=	'nagios.linuxpro.com.br';
my $mailfrom	=	'"Nagios LinuxPro" <nagios@linuxpro.com.br>';
my $mailto	    =	'linuxpro@linuxpro.com.br';
my $timeout	    =	30;
my $mailsubject	=	'';							#	Leave blank
my $mailbody	=	'';							#	Leave blank
my $logfile	    =	'/tmp/mail.log';			#	Put somewhere better
my $debug	    =	0;							#	To enable SMTP session debugging to logfile


################################################################
# Email for nagios
#
# Subject: "Host $HOSTSTATE$ alert for $HOSTNAME$!" $CONTACTEMAIL$
#
# "***** Nagios  *****
# Notification Type: $NOTIFICATIONTYPE$
# Host: $HOSTNAME$
# State: $HOSTSTATE$
# Address: $HOSTADDRESS$
# Info: $HOSTOUTPUT$
# Date/Time: $LONGDATETIME$
#
#################################################################
#
# Commandline options
#
# -n	NOTIFICATIONTYPE
# -h	HOSTNAME
# -s	HOSTSTATE
# -a	HOSTADDRESS
# -i	HOSTOUTPUT
# -d	LONGDATETIME
# -e	CONTACTEMAIL
#
#################################################################


if (not open(LOG,">>$logfile") ) {
	$mailsubject = "Nagios Monitoring Alert: Can't open $logfile for append: $!";
	print STDERR "Nagios Monitoring Alert: Can't open $logfile for append: $!";
	sendmail();
	exit 1;
}


our ($opt_n, $opt_h, $opt_s , $opt_a , $opt_i , $opt_d , $opt_e);
# Get the cmdline options
getopt('nhsaide');
print LOG localtime() . " sending mail to $opt_e with host $opt_h state $opt_s\n";

if (not defined $opt_n or $opt_n eq "") {
	print "option -n not defined!\n";
	$opt_n = "UNDEFINED";
}
elsif (not defined $opt_h or $opt_h eq "") {
	print "option -h not defined!\n";
	$opt_h = "UNDEFINED";
}
elsif (not defined $opt_s or $opt_s eq "") {
	print "option -s not defined!\n";
	$opt_s = "UNDEFINED";
}
elsif (not defined $opt_a or $opt_a eq "") {
	print "option -a not defined!\n";
	$opt_a = "UNDEFINED";
}
elsif (not defined $opt_i or $opt_i eq "") {
	print "option -i not defined!\n";
	$opt_i = "UNDEFINED";
}
elsif (not defined $opt_d or $opt_d eq "") {
	print "option -d not defined!\n";
	$opt_d = "UNDEFINED";
}
elsif (not defined $opt_e or $opt_e eq "") {
	die "CRITICAL: option -e not defined!.  Host $opt_h, Notification: $opt_n, State: $opt_s, Info: $opt_i\n";
}

# You can change the subject here
$mailsubject	=	"Nagios Alerta:[$opt_h] -- Esta:[$opt_s] !!";
$mailto		=	"$opt_e";


$mailbody = <<_END_;
***** Nagios DigitalOcean *****

Notification Type: $opt_n
Host: $opt_h
State: $opt_s
Address: $opt_a

Date/Time: $opt_d

Additional Info:
$opt_i
_END_


sendmail();
print LOG localtime() . " sent mail to $opt_e successfully\n";

exit 0;


#########################################################
sub sendmail {
	my $smtp = Net::SMTP->new(
								$mailhost,
								Hello => $maildomain,
								Timeout => $timeout,
								Debug   => $debug,
								);

	$smtp->mail($mailfrom);
	$smtp->to($mailto);

	$smtp->data();
	$smtp->datasend("To: $mailto\n");
	$smtp->datasend("From: $mailfrom\n");
	$smtp->datasend("Subject: $mailsubject\n");
	$smtp->datasend("\n");
	$smtp->datasend("$mailbody\n");
	$smtp->dataend();

	$smtp->quit;
}

