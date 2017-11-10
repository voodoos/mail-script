mkdir /etc/ssl/keys
openssl req -nodes -x509 -newkey rsa:4096 \
	-keyout /etc/ssl/keys/mail.pem \
	-out /etc/ssl/certs/mail.pem -days 365

openssl req -nodes -x509 -newkey rsa:4096 \
	-keyout /etc/ssl/keys/nginx-${DOMAIN_NAME}.${DOMAIN_EXT}.pem \
	-out /etc/ssl/certs/nginx-${DOMAIN_NAME}.${DOMAIN_EXT}.pem -days 365
