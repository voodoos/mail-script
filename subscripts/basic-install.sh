echo "Setting up hostname..."
hostnamectl set-hostname $1 #.${DOMAIN_NAME}.${DOMAIN_EXT}
sed -i.bak "s/localhost/localhost $1 $1.${DOMAIN_NAME}.${DOMAIN_EXT} mail.${DOMAIN_NAME}.${DOMAIN_EXT}/" /etc/hosts

echo "Installing various tools"
sudo apt-get -q update && sudo apt-get -qqy install git >> install.log

echo "Setting up timezone..."
timedatectl set-timezone 'Europe/Paris'
