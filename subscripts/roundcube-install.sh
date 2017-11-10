MYSQL_RC_PASS=$1
RC_ROOT=${MAIL_VSERV_ROOT}

# Installing required php modules
apt-get -q update && apt-get -qqy install php-mysql php-curl php-mcrypt php-sqlite3 php-imagick php-mbstring php-imap php-pear php-gd php-intl php-ldap php-net-idna2 php-net-smtp php-auth-sasl php-mail-mime php-net-ldap3 php-zip php-net-sieve unzip  >> install.log

# Cloning from git directly into web root :
echo "Cloning Roundcube..."

git clone https://github.com/roundcube/roundcubemail.git ${RC_ROOT}
$(cd ${RC_ROOT} && git checkout release-1.3)

# Installing js dependencies :
${RC_ROOT}/bin/install-jsdeps.sh

# Write right for server over required folders :
chown -R www-data ${RC_ROOT}/temp
chown -R www-data ${RC_ROOT}/logs

# Database config
echo "Creating roudcube database..."
mysql -u root <<EOF
CREATE DATABASE roundcubemail;
EOF
mysql -u root <<EOF
GRANT ALL PRIVILEGES ON roundcubemail.* TO roundcube@localhost
  IDENTIFIED BY '${MYSQL_RC_PASS}';
EOF
mysql roundcubemail <  ${RC_ROOT}/SQL/mysql.initial.sql

# Configuration
echo "Configuring roundcube..."
cp  ${RC_ROOT}/config/config.inc.php.sample  ${RC_ROOT}/config/config.inc.php

sed -i.bak "s/^\$config\['db_dsnw'\].*$/\$config\['db_dsnw'\] = 'mysql:\/\/roundcube:${MYSQL_RC_PASS}@localhost\/roundcubemail';/"  ${RC_ROOT}/config/config.inc.php

sed -i.bak "s/^\$config\['product_name'\].*$/\$config\['product_name'\] = 'One-eyed mail';/"  ${RC_ROOT}/config/config.inc.php

sed -i.bak "s/^\$config\['smtp_server'\].*$/\$config\['smtp_server'\] = 'tls:\/\/localhost';/"  ${RC_ROOT}/config/config.inc.php

NEW_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 24 | head -n 1)

sed -i.bak "s/^\$config\['des_key'\].*$/\$config\['des_key'\] = '${NEW_KEY}';/"  ${RC_ROOT}/config/config.inc.php

echo "
array_push(\$config['plugins'], 'managesieve');

\$config['username_domain'] = '${DOMAIN_NAME}.${DOMAIN_EXT}';
\$config['smtp_auth_type'] = 'PLAIN';
\$config['smtp_conn_options'] = array(
  'ssl'         => array(
     'verify_peer'      => false,
     'verify_peer_name' => false,
  ),
);" >> ${RC_ROOT}/config/config.inc.php

# Installing mabola skin :
git clone https://github.com/EstudioNexos/mabola.git ${RC_ROOT}/skins/mabola
