DOMAIN=$1
EXT=$2
FQDN=$(echo $DOMAIN.$EXT)

# Using acme.sh online installer :
wget -O -  https://get.acme.sh | sh

# Issuing certificate for main domain :
echo $FQDN

/root/.acme.sh/acme.sh --issue -nginx -d $FQDN #-w /srv/nginx
/root/.acme.sh/acme.sh --issue -nginx -d mail.$FQDN #-w /srv/nginx

mkdir /etc/ssl/keys

/root/.acme.sh/acme.sh --install-cert -d $FQDN  \
--key-file       /etc/ssl/keys/nginx-$FQDN.pem  \
--fullchain-file /etc/ssl/certs/nginx-$FQDN.pem \
--reloadcmd     "service nginx force-reload"


/root/.acme.sh/acme.sh --install-cert -d $FQDN  \
--key-file       /etc/ssl/keys/mail.pem  \
--fullchain-file /etc/ssl/certs/mail.pem \
--reloadcmd     "service nginx force-reload"


