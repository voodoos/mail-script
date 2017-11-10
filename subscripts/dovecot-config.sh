MYSQL_POSTFIX_PASS=$1

# dovecot.conf
echo "Editing dovecot.conf..."
sed -i.bak '/^!include_try.*protocol$/a protocols = imap lmtp' /etc/dovecot/dovecot.conf

# 10-mail.conf
echo "Editing 10-mail.conf..."
sed -i.bak 's/^mail_location.*$/mail_location = maildir:\/var\/mail\/vhosts\/%d\/%n/' /etc/dovecot/conf.d/10-mail.conf 
sed -i 's/^#\?mail_privileged_group.*$/mail_privileged_group = vmail/' /etc/dovecot/conf.d/10-mail.conf 

# New user vmail and mail directory conf :
echo "Creating /var/mail/vhosts/${DOMAIN_NAME}.${DOMAIN_EXT} folder..."
mkdir -p /var/mail/vhosts/${DOMAIN_NAME}.${DOMAIN_EXT}
echo "Creating vmail user and adding rights to mail folder..."
groupadd -g 5000 vmail 
useradd -g vmail -u 5000 vmail -d /var/mail
chown -R vmail:vmail /var/mail
chmod -R o-wrx /var/mail

# 10-auth.conf
echo "Editing 10-auth.conf..."
sed -i.bak 's/^#\?disable_plaintext_auth.*$/disable_plaintext_auth = yes/' /etc/dovecot/conf.d/10-auth.conf
sed -i 's/^#\?auth_mechanisms.*$/auth_mechanisms = plain login/' /etc/dovecot/conf.d/10-auth.conf
sed -i 's/^#\?!include auth-system.conf.ext.*$/#!include auth-system.conf.ext/' /etc/dovecot/conf.d/10-auth.conf
sed -i 's/^#\?!include auth-sql.conf.ext.*$/!include auth-sql.conf.ext/' /etc/dovecot/conf.d/10-auth.conf

# auth-sql.conf.ext
echo "Editing auth-sql.conf.ext..."
cat <<EOF > /etc/dovecot/conf.d/auth-sql.conf.ext
passdb {
  driver = sql
  args = /etc/dovecot/dovecot-sql.conf.ext
}
userdb {
  driver = static
  args = uid=vmail gid=vmail home=/var/mail/vhosts/%d/%n
}
EOF

#dovecot-sql.conf.ext
echo "Editing docevot-sql.conf.ext..."
cat <<EOF > /etc/dovecot/dovecot-sql.conf.ext
driver = mysql
connect = host=127.0.0.1 dbname=postfix user=postfix password=${MYSQL_POSTFIX_PASS}
default_pass_scheme = SHA512-CRYPT
password_query = SELECT password FROM mailbox WHERE username = '%u'
EOF


#10-master.cf
echo "Editing 10-master.conf..."
cat prebaked/dovecot-10-master.conf > /etc/dovecot/conf.d/10-master.conf


#10-ssl.cf
echo "Editing 10-ssl.conf..."
sed -i.bak 's/^#\?ssl =.*$/ssl = required/' /etc/dovecot/conf.d/10-ssl.conf
sed -i 's/^#\?ssl_cert =.*$/ssl_cert = <\/etc\/ssl\/certs\/mail.pem/' /etc/dovecot/conf.d/10-ssl.conf
sed -i 's/^#\?ssl_key =.*$/ssl_key = <\/etc\/ssl\/keys\/mail.pem/' /etc/dovecot/conf.d/10-ssl.conf

# SIEVE
#20-lmtp.conf
sed -i.bak 's/#mail_plugins =.*$/mail_plugins = $mail_plugins sieve/' /etc/dovecot/conf.d/20-lmtp.conf
#90-plugin.conf
sed -i.bak 's/sieve =.*$/sieve = \/var\/mail\/vhosts\/%d\/%n\/sieve\/.dovecot.sieve/' /etc/dovecot/conf.d/90-sieve.conf
sed -i 's/sieve_global =.*$/sieve_global = \/var\/lib\/dovecot\/sieve\/default.sieve/' /etc/dovecot/conf.d/90-sieve.conf
sed -i 's/sieve_after =.*$/sieve_after = \/var\/lib\/dovecot\/sieve\/after.d/' /etc/dovecot/conf.d/90-sieve.conf

mkdir -p /var/lib/dovecot/sieve/after.d/

echo 'require ["fileinto","mailbox"];
if header :contains "X-Spam" "Yes" {
 fileinto :create "Junk";
 stop;
    }
' > /var/lib/dovecot/sieve/after.d/junk.sieve

sievec /var/lib/dovecot/sieve/after.d/junk.sieve

#20-managesieve.conf
cat prebaked/dovecot-20-managesieve.conf > /etc/dovecot/conf.d/20-managesieve.conf

mkdir -p  /var/lib/dovecot/sieve
echo "

" > /var/lib/dovecot/sieve/default.sieve

echo "Securing dovecot folder..."
chown -R vmail:dovecot /etc/dovecot
chmod -R o-w /etc/dovecot 
