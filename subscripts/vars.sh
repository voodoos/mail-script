export TODO_FILE=TODO

export WEB_PATH=/srv/nginx
export DEFAULT_VSERV_ROOT=WEB_PATH/default
export MAIL_VSERV_ROOT=WEB_PATH/mail

#############
#  SYSTEM VARS
##########

#echo -n "Hello ! What's your name ? (used to configure default mysql and postfixadmin accounts, you can enter the same as your UNIX username)"
USERP=ulysse
#read USERP
export USERP

#echo -n "Choose a nice hostname for your server (will be append in front of your domain name): "
HOSTNAME=polypheme
#read HOSTNAME
export HOSTNAME

#echo -n "Enter ssh port to be allowed in UFW: "
SSH_PORT=22
#read SSH_PORT

#echo -n "Enter your domain name (without the last part .fr .org etc): "
DOMAIN_NAME=cyclo
#read DOMAIN_NAME
#echo -n "Enter the last part of your domain name (fr org etc): "
DOMAIN_EXT=pe
#read DOMAIN_EXT

export DOMAIN_NAME
export DOMAIN_EXT
export DOMAIN=${DOMAIN_NAME}.${DOMAIN_EXT}

#############
#  MYSQL VARS
##########
#echo -n "Choose a strong root password for the database: "
#read -s MYSQL_ROOT_PASS
#echo
MYSQL_ROOT_PASS=totoro

export DB_USER=$USERP
#echo -n "Choose a password for your personnal dbuser (named after your unix account $USER): "
#read -s MYSQL_USER_PASS
#echo
MYSQL_USER_PASS=$MYSQL_ROOT_PASS
MYSQL_USER=$USERP

#echo -n "Choose a password for postfix's mysql user (strong, no need to remember): "
#read -s MYSQL_POSTFIX_PASS
#echo
MYSQL_POSTFIX_PASS=$MYSQL_ROOT_PASS

#echo -n "Choose a password for roundcube's mysql user (strong, no need to remember): "
#read -s MYSQL_RC_PASS
#echo
MYSQL_RC_PASS=$MYSQL_ROOT_PASS

#############
#  POSTFIXADMIN VARS
##########
#echo -n "Chosse a strong password that you can remenber for your main postfixadmin account"
#read -s PFADMIN_PASS
#echo
PFADMIN_PASS=$MYSQL_ROOT_PASS

#############
#  DOVECOT VARS
##########
#echo -n "Choose a number of rounds such as SHA512 hashes take around 250ms to compute"
#read DV_ROUNDS
DV_ROUNDS=400000

###########
# RSPAMD VARS
########

export RSPAMD_DIR="/etc/rspamd"
export RSPAMD_CONF_DIR=${RSPAMD_DIR}/local.d


#echo -n "Chosse a strong password for rspamd webui"
#read -s RSPAMD_PASS
#echo
RSPAMD_PASS=$MYSQL_ROOT_PASS



bash subscripts/print.sh  "Make sure your DNS are properly configured :"
echo "$DOMAIN_NAME.$DOMAIN_EXT must have a A record pointing to your server"
echo "mail.$DOMAIN_NAME.$DOMAIN_EXT must have a A record pointing to your server"
echo
echo -n "Are you ready ? then pres ENTER !"
read R
