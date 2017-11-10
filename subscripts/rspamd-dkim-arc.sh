
# Generating DKIM and ARC keys
mkdir -p /var/lib/rspamd/dkim
DKIM=$(sudo rspamadm dkim_keygen -k /var/lib/rspamd/dkim/${DOMAIN}.dkim.key -b 2048 -s dkim -d ${DOMAIN}
)
echo "Add the following entry to your DNS zone for DKIM (and ARC) authentification :"  >> ${TODO_FILE}
echo ${DKIM} >> ${TODO_FILE}

chown -R _rspamd._rspamd /var/lib/rspamd/dkim
chmod 640 /var/lib/rspamd/dkim/*.key



echo 'path = "/var/lib/rspamd/dkim/$domain.$selector.key";
selector = "dkim";
allow_username_mismatch = true;
' >>  /etc/redis/dkim_signing.conf
echo 'path = "/var/lib/rspamd/dkim/$domain.$selector.key";
selector = "dkim";
allow_username_mismatch = true;
' >>  /etc/redis/arc.conf

systemctl restart rspamd
