RSPAMD_PASS=$1


# Install steps from official page :
apt-get install -y lsb-release wget # optional
CODENAME=`lsb_release -c -s`
wget -O- https://rspamd.com/apt-stable/gpg.key | apt-key add -
echo "deb http://rspamd.com/apt-stable/ $CODENAME main" > /etc/apt/sources.list.d/rspamd.list
echo "deb-src http://rspamd.com/apt-stable/ $CODENAME main" >> /etc/apt/sources.list.d/rspamd.list
apt-get update
apt-get --no-install-recommends -y install rspamd


# Creating local conf files
echo "Creating local conf files for Rspamd..."

echo 'bind_socket = "localhost:11333";
' > ${RSPAMD_CONF_DIR}/worker-normal.inc

echo 'bind_socket = "localhost:11332";
milter = yes;
timeout = 120s;
upstream "local" {
  default = yes;
  self_scan = yes;
}
' > ${RSPAMD_CONF_DIR}/worker-proxy.inc

HASHPASS=$(rspamadm pw -p ${RSPAMD_PASS})

echo "password = \"${HASHPASS}\";
enable_password = \"${HASHPASS}\";
bind_socket = \"localhost:11334\";
" > ${RSPAMD_CONF_DIR}/worker-controller.inc

echo 'servers = "127.0.0.1";
backend = "redis";
autolearn = true;
' > ${RSPAMD_CONF_DIR}/classifier-bayes.conf

echo 'use = ["authentication-results", "x-spam-status"];
authenticated_headers = ["authentication-results"];
' > ${RSPAMD_CONF_DIR}/milter_headers.conf

echo 'action = "no action";
' > ${RSPAMD_CONF_DIR}/replies.conf

echo 'redirector_hosts_map = "/etc/rspamd/redirectors.inc";
' > ${RSPAMD_CONF_DIR}/surbl.conf

echo 'enabled = true;
' > ${RSPAMD_CONF_DIR}/url_reputation.conf

echo 'enabled = true;
' > ${RSPAMD_CONF_DIR}/url_tags.conf

echo 'servers = "127.0.0.1";
' > ${RSPAMD_CONF_DIR}/redis.conf

echo 'openphish_enabled = true;
phishtank_enabled = true;
' > ${RSPAMD_CONF_DIR}/phishing.conf

echo 'actions {
  add_header = 6;
  greylist = 4;
}
' > ${RSPAMD_CONF_DIR}/metrics.conf

#
# Installing redis
echo "Installing redis..."
apt-get install -y redis-server

echo "Configuring redis..."

sed -i.bak "s/^bind 127\.0\.0\.1.*$/bind 127.0.0.1 ::1/" /etc/redis/redis.conf

echo '
maxmemory 250mb
maxmemory-policy volatile-lru
' >>  /etc/redis/redis.conf

# Configuring Postfix


postconf \
  milter_protocol=6 \
  milter_default_action=accept \
  smtpd_milters='inet:localhost:11332' \
  non_smtpd_milters='$smtpd_milters' \
  milter_mail_macros='  i {mail_addr} {client_addr} {client_name} {auth_authen}'

# Starting !
echo "Restarting redis and rspamd"
systemctl restart redis
systemctl restart rspamd
