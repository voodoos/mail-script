#Installing UFW :
apt-get -q update && apt-get -qy install ufw >> install.log

#Before enabling, we allow ssh and deny everything else :
ufw default deny incoming
ufw default allow outgoing
ufw allow in $1/tcp
yes | ufw enable
