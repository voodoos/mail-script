cp prebaked/nginx-roundcube /etc/nginx/sites-available/roundcube


sed -i.bak "s/SERVNAMEHERE/mail.${DOMAIN}/" /etc/nginx/sites-available/roundcube

ln -s /etc/nginx/sites-available/roundcube /etc/nginx/sites-enabled/roundcube

service nginx restart
