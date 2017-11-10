DB_PS_PASS=$1
USER=$2
DOMAIN_NAME=$3
DOMAIN_EXT=$4
PFADMIN_PASS=$5
DV_ROUNDS=$6

PFADMIN_PATH=/srv/nginx/default/postfixadmin

# Cloning from git directly into web root :
git clone https://github.com/postfixadmin/postfixadmin.git ${PFADMIN_PATH}
$(cd /srv/nginx/postfixadmin/ && git checkout 0951629a483c7bfa806c01f686652ce47164a180)

# Creating database :

echo "Adding postfix database and user..."

mysql -u root <<EOF
  CREATE DATABASE postfix;
  CREATE USER 'postfix'@'localhost' IDENTIFIED BY '$DB_PS_PASS';
  GRANT ALL PRIVILEGES ON \`postfix\` . * TO 'postfix'@'localhost';
EOF

echo "Configuring PostfixAdmin"
cat <<EOF   > ${PFADMIN_PATH}/config.local.php 
<?php
\$CONF['database_type'] = 'mysqli';
\$CONF['database_user'] = 'postfix';
\$CONF['database_password'] = '$DB_PS_PASS';
\$CONF['database_name'] = 'postfix';
\$CONF['configured'] = true;
\$CONF['encrypt'] = 'dovecot:SHA512-CRYPT';
\$CONF['dovecotpw'] = '/usr/bin/doveadm pw -r 400000';
?>
EOF

# Write right for server over templates folder :
mkdir  ${PFADMIN_PATH}/templates_c
chown -R www-data  ${PFADMIN_PATH}/templates_c

# We execute the setup once to initialize database :
curl --insecure https://localhost/postfixadmin/setup.php >> install.log
curl localhost/postfixadmin/setup.php >> install.log

# We add an ALL domain :
mysql -u root <<EOF
INSERT INTO \`postfix\`.\`domain\` (\`domain\`, \`description\`, \`aliases\`, \`mailboxes\`, \`maxquota\`, \`quota\`, \`transport\`, \`backupmx\`, \`created\`, \`modified\`, \`active\`)
VALUES ('ALL', '', '0', '0', '0', '0', '', '0', now(), now(), '1');
EOF

# We add a superadmin user :
SHAPASS=$(doveadm pw -s SHA512-CRYPT -p ${PFADMIN_PASS} -r ${DV_ROUNDS})

mysql -u root <<EOF
INSERT INTO \`postfix\`.\`admin\` (\`username\`, \`password\`, \`superadmin\`, \`created\`, \`modified\`, \`active\`) 
VALUES ('$USER@$DOMAIN_NAME.$DOMAIN_EXT', '${SHAPASS}', '1', now(), now(), '1');
EOF

# We add ALL domains to super admin :
mysql -u root <<EOF
INSERT INTO \`postfix\`.\`domain_admins\` (\`username\`, \`domain\`, \`created\`, \`active\`)
VALUES ('$USER@$DOMAIN_NAME.$DOMAIN_EXT','ALL', now(), '1');
EOF

# We add a domain :
mysql -u root <<EOF
INSERT INTO \`postfix\`.\`domain\` (\`domain\`, \`description\`, \`aliases\`, \`mailboxes\`, \`maxquota\`, \`quota\`, \`transport\`, \`backupmx\`, \`created\`, \`modified\`, \`active\`)
VALUES ('$DOMAIN_NAME.$DOMAIN_EXT', 'Main domain', '10', '10', '10', '2048', 'virtual', '0', now(), now(), '1');
EOF

# We delete setup.php for increased security :
rm  ${PFADMIN_PATH}/setup.php
