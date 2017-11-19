bash subscripts/print.sh "Upgrading via apt-get"
apt-get update
apt-get -y dist-upgrade >> ${LOG}

bash subscripts/print.sh 'Performing some autocleaning'
apt-get -y autoremove
apt-get clean
