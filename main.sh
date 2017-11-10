#!/usr/bin/env bash
set -o errexit
set -o pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

DO="RSPAMD"

# -1 We get the config vars :
source subscripts/vars.sh
touch ${TODO_FILE}

# 0 - We update the machine :
if [[ ${DO} == *"ALL"* ]]
then
    bash subscripts/dist-upgrade.sh
fi

# 0 - We do some basic configuration :
if [[ ${DO} == *"ALL"* ]]
then
    bash subscripts/print.sh "Basic setup"
    bash subscripts/basic-install.sh $HOSTNAME
fi

# 1 - Firewall (UFW)
if [[ ${DO} == *"ALL"* ]]
then
    bash subscripts/print.sh "Installing UFW"
    bash subscripts/ufw-install.sh $SSH_PORT
fi

# 2 - fail2ban
if [[ ${DO} == *"ALL"* ]]
then
    bash subscripts/print.sh "Installing fail2ban"
    bash subscripts/f2b-install.sh
fi

# 3 - mariadb
if [[ ${DO} == *"ALL"* ]]
then
    bash subscripts/print.sh "Installing mariadb"
    bash subscripts/mdb-install.sh $MYSQL_ROOT_PASS $MYSQL_USER $MYSQL_USER_PASS
fi

# 4 - Nginx / php-fpm
if [[ ${DO} == *"ALL"* ]] || [[ ${DO} == *"NGINX"* ]]
then
    bash subscripts/print.sh "Installing nginx"
    sudo bash subscripts/nginx-install.sh
    sudo bash subscripts/nginx-f2b.sh
fi

# 5 - Adminer
if [[ ${DO} == *"ALL"* ]]
then
    bash subscripts/print.sh "Installing adminer"
    bash subscripts/adminer-install.sh
fi

# 6 - Let's Encrypt
if [[ ${DO} == *"ALL"* ]]
then
    bash subscripts/print.sh "Installing acme.sh with a certificate for domain root"
    
    if [ ${DO} == *"SIGNED"* ]
    then
	bash subscripts/acme-install.sh $DOMAIN_NAME $DOMAIN_EXT
    else
	bash subscripts/selfsigned-certs.sh
    fi

    bash subscripts/nginx-ssl-config.sh
fi

# 7 - Install postfix and dovecot
if [[ ${DO} == *"ALL"* ]] || [[ ${DO} == *"MAIL"* ]]
then
    bash subscripts/print.sh "Installing postfix and dovecot"
    sudo debconf-set-selections <<< "postfix postfix/mailname string mail.${DOMAIN_NAME}.${DOMAIN_EXT}"
    sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"

    apt-get update && apt-get remove exim4 && apt-get -y install postfix postfix-mysql dovecot-core dovecot-imapd dovecot-lmtpd dovecot-mysql dovecot-sieve dovecot-managesieved >> install.log
fi

echo "Stopping postfix and dovecot..."
sudo service postfix stop
sudo service dovecot stop

# 8 - Postscriptadmin and MYySQL database for virtual users
if [[ ${DO} == *"ALL"* ]] || [[ ${DO} == *"MAIL"* ]]
then
    bash subscripts/print.sh "Installing postfix-admin"
    bash subscripts/postfixadmin-install.sh \
	 $MYSQL_POSTFIX_PASS $MYSQL_USER $DOMAIN_NAME $DOMAIN_EXT $PFADMIN_PASS $DV_ROUNDS
fi

# 9 - Postfix and Dovecot config
if [[ ${DO} == *"ALL"* ]] || [[ ${DO} == *"MAIL"* ]] || [[ ${DO} == *"MCONF"* ]]
then
    bash subscripts/print.sh "Configuring  postfix and dovecot"
    bash subscripts/postfix-config.sh ${MYSQL_POSTFIX_PASS}
    bash subscripts/dovecot-config.sh ${MYSQL_POSTFIX_PASS}
    bash subscripts/ufw-mail-config.sh
fi

# 9bis - PostSRSD
if [[ ${DO} == *"ALL"* ]] || [[ ${DO} == *"MAIL"* ]] || [[ ${DO} == *"SRS"* ]]
then
    bash subscripts/print.sh "Installing  postSRSd"
    bash subscripts/srs-install.sh
fi

# 10 - Roundcube
if [[ ${DO} == *"ALL"* ]] || [[ ${DO} == *"MAIL"* ]]  || [[ ${DO} == *"ROUNDCUBE"* ]]
then
    bash subscripts/print.sh "Installing Roundcube webmail"
    bash subscripts/roundcube-install.sh ${MYSQL_RC_PASS}
    bash subscripts/nginx-roundcube-config.sh
fi

# 11 - Rspamd
if [[ ${DO} == *"ALL"* ]] || [[ ${DO} == *"MAIL"* ]] || [[ ${DO} == *"RSPAMD"* ]]
then
    bash subscripts/print.sh "Installing Rspamd"
    bash subscripts/rspamd-install.sh ${RSPAMD_PASS}
    bash subscripts/rspamd-dkim-arc.sh
    #bash subscripts/nginx-rspamd-config.sh
fi

echo "Starting postfix and dovecot..."
sudo service postfix start
sudo service dovecot start

# # Test you should run
echo "You should check firewall rules with sudo ufw status verbose"
echo "You should check that pathinfo is disabled by browing to your domain's root."
echo "You should check that headers are not showing nginx version by issuing the command url -I domain.tld"
echo "You should check you have a readonly dbuser by connecting to doain.tld/adminer.php"
echo "You should try to connect to postfixadmin"
