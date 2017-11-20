DOMAIN=$1
EXT=$2
FQDN=$(echo $DOMAIN.$EXT)

# Using acme.sh online installer :
wget -O -  https://get.acme.sh | sh

# Issuing certificate for main domain :
echo $FQDN

# Initializing crontab
(crontab -l)

# Stopping Nginx to allow standalone server magic
service nginx stop

echo "Issuing cert for $FQDN"
/root/.acme.sh/acme.sh --issue -d $FQDN --standalone  #-w /srv/nginx/default
echo "Issuing cert for mail.$FQDN"
/root/.acme.sh/acme.sh --issue -d mail.$FQDN --standalone  #-w /srv/nginx/default

service nginx start

mkdir /etc/ssl/keys

/root/.acme.sh/acme.sh --install-cert -d $FQDN  \
--key-file       /etc/ssl/keys/nginx-$FQDN.pem  \
--fullchain-file /etc/ssl/certs/nginx-$FQDN.pem \
--reloadcmd     "service nginx force-reload"


/root/.acme.sh/acme.sh --install-cert -d "mail.${FQDN}"  \
--key-file       /etc/ssl/keys/mail.pem  \
--fullchain-file /etc/ssl/certs/mail.pem \
--reloadcmd     "service nginx force-reload"


