#Installing NGINX, php and some useful modules
apt-get -q update && apt-get -qqy install nginx php-fpm php-mysql php-curl php-mcrypt php-sqlite3 php-imagick php-mbstring php-imap  >> install.log

# Firewall rule for http and https ports:
ufw allow in 80/tcp
ufw allow in 443/tcp

# Fix pathinfo security breach:
sed -i.bak 's/^;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/7.0/fpm/php.ini
#sed -i.bak 's/^;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/7.0/fpm/php.ini

#Set PHP timezone:
sed -i.bak 's/^;date.timezone.*/date.timezone = Europe\/Paris/' /etc/php/7.0/fpm/php.ini

# Hardening NGinx:
#Prevent NGINX from displaying verbose headers :
sed -i.bak 's/# server_tokens off;/server_tokens off;/' /etc/nginx/nginx.conf


# Quick example site with phpinfo :
echo "toto ${DOMAIN} ${WEB_ROOT} ${DEFAULT_VSERV_ROOT}"
mkdir -p ${DEFAULT_VSERV_ROOT}
cp prebaked/info-site /etc/nginx/sites-available/ 
ln -s /etc/nginx/sites-available/info-site /etc/nginx/sites-enabled/info-site
rm /etc/nginx/sites-enabled/default

cp prebaked/index.php ${DEFAULT_VSERV_ROOT}/index.php

service php7.0-fpm restart
sudo service nginx restart
