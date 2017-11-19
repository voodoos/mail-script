echo "Installing Prometheus..."

mkdir /etc/prometheus
(cd /tmp && wget https://github.com/prometheus/prometheus/releases/download/v2.0.0/prometheus-2.0.0.linux-amd64.tar.gz && tar -xzf prometheus-2.0.0.linux-amd64.tar.gz -C /etc/prometheus --strip-components=1 && rm /tmp/prometheus-2.0.0.linux-amd64.tar.gz)


apt-get install apt-transport-https &> ${LOG}

echo "Installing Grafana"

echo "deb https://packagecloud.io/grafana/stable/debian/ jessie main" >> /etc/apt/sources.list
curl https://packagecloud.io/gpg.key | apt-key add -
apt-get update #&> ${LOG}
apt-get install grafana #&> ${LOG}

echo "Configuring Grafana for use with Nginx..."
sed -i.bak "s/^;domain.*$/domain=${DOMAIN}/" /etc/grafana/grafana.ini
sed -i.bak "s/^;root_url.*$/root_url=%(protocol)s:\/\/%(domain)s:\/grafana/" /etc/grafana/grafana.ini

echo "Making Grafana start on boot..."
/bin/systemctl daemon-reload
/bin/systemctl enable grafana-server


echo "Starting Grafana..."
service grafana-server restart

echo "Goto ${DOMAIN}/grafana and change the default admin/admin password." >> ${TODO_FILE}
