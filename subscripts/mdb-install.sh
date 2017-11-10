#Installing UFW :
apt-get -q update && apt-get -qqy install mariadb-server >> install.log

# Securing installation with root pasw passed in argument 1 :
MYSQL_PASS=$1
DB_USER=$2
DB_PASS=$3
# Now we secure the mysql installation :
echo "Securing mariadb installation..."
mysql -u root <<-EOF
UPDATE mysql.user SET Password=PASSWORD('$MYSQL_PASS') WHERE User='root';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
FLUSH PRIVILEGES;
EOF

# And we add a new user :
echo "Adding a read-only user..."
mysql -u root <<-EOF
CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';
GRANT SELECT ON *.* TO '$DB_USER'@'%';
EOF
