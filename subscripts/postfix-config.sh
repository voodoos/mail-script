MYSQL_POSTFIX_PASS=$1
FQDN=${DOMAIN_NAME}.${DOMAIN_EXT}

# Du passé faisont table rase !
rm /etc/postfix/main.cf
touch /etc/postfix/main.cf

# Main.cf

postconf \
  myhostname=${HOSTNAME}.${FQDN} \
  mydomain=${FQDN} \
  myorigin='$mydomain' \
  mydestination='$myhostname, mail.localhost, localhost' \
  mynetworks_style=host \
\
  relay_domains='' \
  relayhost='' \
  mailbox_size_limit=0 \
  inet_interfaces=all \
  biff=no \
  append_dot_mydomain=no \
  compatibility_level=2 \
\
  smtp_tls_security_level=may \
  smtp_tls_ciphers=medium  \
  smtp_tls_loglevel=1 \
  smtp_tls_session_cache_database='btree:${data_directory}/smtp_scache' \
  smtp_tls_fingerprint_digest=sha1 \
\
  smtpd_tls_cert_file=/etc/ssl/certs/mail.pem \
  smtpd_tls_key_file=/etc/ssl/keys/mail.pem \
  smtpd_use_tls=yes \
  smtpd_tls_security_level=may \
  smtpd_tls_auth_only=yes \
  smtpd_tls_protocols='!SSLv2, !SSLv3' \
  smtpd_tls_loglevel=1 \
  smtpd_tls_ciphers=medium  \
  smtpd_tls_session_cache_database='btree:${data_directory}/smtpd_scache' \
  smtpd_tls_fingerprint_digest=sha1 \
  smtpd_tls_received_header=yes \
  smtpd_helo_required=yes \
\
  smtpd_sasl_type=dovecot \
  smtpd_sasl_path=private/auth \
  smtpd_sasl_auth_enable=yes \
  smtpd_sasl_authenticated_header=yes \
  smtpd_recipient_restrictions='permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination' \
\
  smtpd_relay_restrictions='permit_mynetworks permit_sasl_authenticated defer_unauth_destination' \
\
  alias_maps=hash:/etc/aliases \
  alias_database=hash:/etc/aliases \
\
  virtual_mailbox_domains='mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf' \
  virtual_mailbox_maps='mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf' \
  virtual_alias_maps='mysql:/etc/postfix/mysql-virtual-alias-maps.cf' \
  virtual_transport='lmtp:unix:private/dovecot-lmtp'
	 
postconf -n

# Configuration MySQL :

cat <<EOF   > /etc/postfix/mysql-virtual-mailbox-domains.cf 
hosts = 127.0.0.1
user = postfix
password = ${MYSQL_POSTFIX_PASS}
dbname = postfix
query = SELECT domain FROM domain WHERE domain='%s' and backupmx=0 and active=1
EOF

cat <<EOF   > /etc/postfix/mysql-virtual-mailbox-maps.cf 
hosts = 127.0.0.1
user = postfix
password = ${MYSQL_POSTFIX_PASS}
dbname = postfix
query = SELECT maildir FROM mailbox WHERE username='%s' AND active=1
EOF

cat <<EOF   > /etc/postfix/mysql-virtual-alias-maps.cf 
hosts = 127.0.0.1
user = postfix
password = ${MYSQL_POSTFIX_PASS}
dbname = postfix
query = SELECT goto FROM alias WHERE address='%s' AND active=1
EOF

echo "Testing postfix/mysql conf should print" ${FQDN} ":"
postmap -q ${FQDN} mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf

# master.cf (enabling submission)
postconf -Me submission/inet='submission inet n - y - - smtp'
postconf -P \
	 "submission/inet/syslog_name=postfix/submission" \
	 "submission/inet/smtpd_tls_security_level=encrypt" \
	 "submission/inet/smtpd_sasl_auth_enable=yes" \
	 "submission/inet/smtpd_reject_unlisted_recipient=no" \
	 "submission/inet/smtpd_client_restrictions=permit_sasl_authenticated,reject" \
	 "submission/inet/milter_macro_daemon_name=ORIGINATING"


echo "Securing postfix folder."
chmod -R o-rwx /etc/postfix

#smtp(d)_tls_ciphers = medium :
# « Because cleartext is not stronger than medium.  If you make TLS 
# impossible for peers that only support medium, they'll do cleartext. 
# Raising the floor too high lowers security.  Security is improved 
# by raising the ceiling (stronger best supported ciphers), not 
# raising the floor (removing weak ciphers that are still best 
# available for a non-negligible set of peers). »

#smtp(d)_tls_security_level=may
# Other MTAs will always connect to port 25; smtpd_tls_security_level 
# must be set to "may" on port 25, or as the main.cf setting. 

# Port 587 will only be used by clients, unauthenticated connections 
# should be rejected; -o smtpd_tls_security_level=encrypt should be 
# set on the master.cf submission service to require TLS from clients. 

# Clients may also connect to port 25 if your local policy allows it, 
# although most sites require clients use 587.  So you can set main.cf 
# "smtpd_tls_auth_only = yes" to require that clients use TLS before 
# they can use AUTH. 

#smtp(d)_tls_fingerprint_digest=sha1
# The default algorithm is md5; this is consistent with the backwards 
# compatible setting of the digest used to verify client certificates in the SMTP server.

# The best practice algorithm is now sha1. Recent advances in hash function
# cryptanalysis have led to md5 being deprecated in favor of sha1. 
# However, as long as there are no known "second pre-image" attacks against md5, 
# its use in this context can still be considered safe.

# While additional digest algorithms are often available with OpenSSL's libcrypto, 
# only those used by libssl in SSL cipher suites are available to Postfix. For now 
# this means just md5 or sha1.

#smtpd_helo_required=yes
# http://en.linuxreviews.org/HOWTO_Stop_spam_using_Postfix
# The first measure you may want is to reject MTA software which doesn't even say hello. 
# AFAIK the only MTA software which doesn't do this is only used for spam.

#smtpd_recipient_restrictions = permit_sasl_authenticated, permit_mynetworks, reject_invalid_hostname, reject_unknown_recipient_domain, reject_unauth_destination, reject_non_fqdn_hostname, reject_non_fqdn_sender, reject_non_fqdn_recipient, reject_unauth_pipelining
