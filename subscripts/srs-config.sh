# Install postsrsd
apt-get update && apt-get install -y postsrsd > /dev/null

# Add postfix configuration parameters for postsrsd
postconf -e "sender_canonical_maps = tcp:127.0.0.1:10001"
postconf -e "sender_canonical_classes = envelope_sender"
postconf -e "recipient_canonical_maps = tcp:127.0.0.1:10002"
postconf -e "recipient_canonical_classes = envelope_recipient,header_recipient"


# Start SRS daemon
sudo service postsrsd restart
#Reload postfix
sudo service postfix reload
