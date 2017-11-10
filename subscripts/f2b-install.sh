#Installing Ufail2ban :
apt-get -q update && apt-get -qy install fail2ban >> install.log

# Configuring fail2ban to work with UFW and watch SSH connections :
# TODO move adminer related config to adminer script
touch /etc/fail2ban/jail.local
echo "[ssh]
enabled = true 
port = 22 
filter = sshd 
action = ufw[application=\"OpenSSH\", blocktype=reject] 
logpath = /var/log/auth.log 
maxretry = 3" >  /etc/fail2ban/jail.local

echo "[sshd]
enabled = false" >  /etc/fail2ban/jail.d/defaults-debian.conf

service fail2ban restart
